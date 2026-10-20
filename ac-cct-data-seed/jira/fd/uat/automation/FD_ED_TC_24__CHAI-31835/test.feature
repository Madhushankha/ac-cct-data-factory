Given the user opens the agentic chatbot via Mobile Web Browser (iPhone Safari or Android Chrome)
Then the system detects: Channel = Mobile Web
And the system applies: Responsive rendering rules (components adapt to smaller screen width)
Then the chatbot displays greeting (GLOB-01) � Mobile Web responsive format:
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
And the chatbot displays interactive buttons (responsive � stacked vertically on mobile):
� [English]
� [French]
NOTE: On desktop web, buttons may be side-by-side. On mobile web, buttons stack vertically to fit screen width.
Then user taps "English"
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight from Toronto to Vancouver was delayed 4 hours due to a crew issue. I'd like to check if I'm eligible for compensation"
When the chatbot identifies flight disruption intent
Then the chatbot checks: Is this a third-party submission? ? NO
Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation."
LEGAL DISCLAIMER:
Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need your booking reference, the name associated to the booking and any receipts you'd like to be reimbursed for. If your claim is eligible, you may also need to provide your address, contact information and where you'd like the funds deposited. Would you like to get started?"
And the chatbot displays interactive buttons (stacked vertically):
� [Yes, let's get started]
� [No, not right now]
And the user taps "Yes, let's get started"
IDENTIFICATION (GenUC-01) � Mobile Web:
Then the chatbot responds:
"I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you."
And the chatbot responds:
"Please provide your full name exactly as it appears on your ticket, including any middle names if applicable."
And the user types "Samantha Wong"
Then the chatbot responds:
"Thanks, Samantha! And, what is your booking reference number?"
And the user types "TC244"
Then the chatbot searches Trip Tracer for PNR: TC244
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer
AUTHENTICATION (GenUC-05) � Mobile Web:
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays interactive buttons (stacked vertically):
� [Email: s***@gmail.com]
� [Phone: +1***345]
And the user taps "Email: s***@gmail.com"
Then the chatbot responds:
"I've sent a verification code to your email, please enter it within 15 minutes of receiving it."
And the user types the OTP code "629184"
Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5)
Then the chatbot responds:
"Your verification was successful. Let's proceed to the next step."
GROUP BOOKING CHECK:
Then the system checks Trip Tracer for group booking identifier
And group booking identifier = NOT PRESENT
And system proceeds to passenger selection
PASSENGER SELECTION (GenUC-06) � Mobile Web:
Then the chatbot asks:
"How many people are on your claim?"
And the chatbot displays a passenger card (responsive � full width on mobile):
"I found 1 passenger on this booking:
[Passenger Card � Responsive]
� Samantha Wong (Adult)
[Include ?] [Exclude ?]"
NOTE: On desktop, passenger cards may display side-by-side for multiple passengers. On mobile, they stack vertically with full-width cards. Checkboxes/buttons are touch-friendly (minimum 44px tap target).
And the user taps "Include ?"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED
JOURNEY SELECTION (GenUC-08) � Mobile Web (RESPONSIVE FLIGHT CARD):
Then the chatbot retrieves booking details and displays a responsive flight card:
[Flight Card � Mobile Responsive]
???????????????????????????????
? ? AC 103 ?
? Toronto (YYZ) ? Vancouver ?
? (YVR) ?
? June 1, 2026 ?
? Arrival Delay: 4 hours ?
? Status: ARRIVED LATE ?
? [Select this journey] ?
???????????????????????????????
NOTE: On desktop, the flight card may be wider with more horizontal layout. On mobile, it adapts to full-width with stacked elements. The "Select this journey" button is full-width and touch-friendly.
And the user taps "Select this journey"
SEGMENT CHECK:
Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18
DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for this passenger + journey combination
72-HOUR CHECK:
Then the chatbot checks: Hours since last leg arrival ? >72 hours ? PROCEED
CLAIM TIME LIMIT CHECK:
Then the chatbot checks: Filing deadline ? within limitation ? PROCEED
REGIME DETERMINATION:
Then the system determines: Origin = YYZ (Canada) ? APPR
And the system checks: Distance YYZ?YVR = ~3,350 km ? Long-haul (domestic)
TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS Evaluates:
APPR: Delay 3�6h, Controllable ? ELIGIBLE
Compensation: CAD $400
FRAUD SCREENING � CYBERSOURCE (GLOB-05):
Then the chatbot sends case details to CyberSource for fraud screening
And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected)
ELIGIBLE RESULT (FD-05a) � Mobile Web:
Then the chatbot displays:
"I've checked your flight details, and it looks like flight AC 103 from Toronto (YYZ) to Vancouver (YVR) was delayed by about 4 hours. Based on the Canadian Air Passenger Protection Regulations (APPR), you may be eligible for compensation of $400 CAD for this delay. I'll guide you through the next steps so we can get your claim submitted and processed as quickly as possible."
CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW � Mobile Web:
Then the chatbot asks:
"Thank you for confirming. In which country will your reimbursement be deposited?"
And the chatbot displays a searchable dropdown (mobile-optimized � opens native mobile picker or scrollable list):
NOTE: On desktop, this is a standard dropdown. On mobile web, it opens the native OS picker (iOS wheel picker / Android dropdown) for better touch interaction.
And the user selects "Canada"
Then the system determines: Country = Canada ? Currency = CAD
CASH vs AC WALLET CHECK (FD-06b):
Then the chatbot checks: Does customer have Aeroplan number on booking? ? No
Then the chatbot responds: "You are entitled to receive a $400 CAD compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed?"
And an alert information is displayed: "Please note that payments will be deposited in your local currency."
And the chatbot displays buttons (stacked vertically):
� [Yes, proceed]
� [No, cancel]
And user taps "Yes, proceed"
Then system checks which payment method is mapped based on country of residence ? Interac e-Transfer (Canada)
PAYMENT METHOD � INTERAC E-TRANSFER (FD-07) � Mobile Web:
Then the chatbot responds:
"Your payment will be made through Interac e-Transfer. Before we move forward, please provide the email address where you'd like to receive the transfer."
NOTE: On mobile web, the email input field triggers the mobile keyboard with @ symbol readily accessible. Input field is full-width for easy typing on small screens.
And the user types "samantha.wong@gmail.com"
Then the chatbot confirms: "Thank you. Your Interac e-Transfer details have been recorded."
Then system checks that IDV is not completed
IDENTITY VERIFICATION � PERSONA (FD-07b) � Mobile Web:
Then the chatbot responds:
"I must verify your identity for payment security. Please click here to get started"
And chatbot displays a full-width button: [Get verified]
NOTE: On mobile web, the "Get verified" button is full-width and touch-friendly. Persona IDV opens in the same mobile browser (in-app browser or new tab). Camera access for ID photo and selfie works natively on mobile.
When user taps "Get verified"
Then system checks if IDV at Payment
Then system checks if user have consented to IDV
And the chatbot sends Persona IDV link to the customer
And Persona opens in the mobile browser
And the customer completes identity verification via Persona:
? Camera access: Granted (mobile native camera) ?
? ID photo capture: Mobile camera used (not file upload) ?
? Selfie capture: Front-facing camera used ?
? Touch interactions: All touch-friendly ?
And Persona returns: IDV PASS
Then the chatbot responds:
"Your identity has been verified successfully. Let's proceed to finalize your claim."
CLAIM AMOUNT CONFIRMATION FLOW � Mobile Web:
Then the chatbot responds: "Please review your compensation details:
Deposit Amount: $400 CAD
Payment Method: Interac e-Transfer
After submission, you will receive a confirmation email summarizing your eligibility, claim details and next steps.
Would you like me to submit your claim?"
And an alert information is displayed: "Please note that the payment details cannot be changed after submission."
And the chatbot displays buttons (stacked vertically):
� [Yes, submit my claim]
� [No, go back]
When the user taps "Yes, submit my claim"
CASE CREATION (GLOB-09):
Then the chatbot responds: "Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your claim details, and a second email that will include the secure link where you'll provide your information."
And an alert information is displayed: "Claim submission successful!"
And the system appends the booking record to the case automatically
NOTIFICATION (Adobe):
Then the system triggers notification via Adobe:
And an eligible notification email is sent to s***@gmail.com
And the email contains: Case Reference, compensation amount ($400 CAD), regulation (APPR), flight details, channel (Mobile Web), next steps, tracking link
END FLOW (GLOB-11) � Mobile Web:
Then the chatbot offers:
"Is there anything I can help you with?"
And the chatbot displays buttons (stacked vertically):
� [Yes, I have another request]
� [No, I'm done]
And the user taps "No, I'm done"
Then the chatbot responds "Thank you for choosing Air Canada."
MOBILE WEB RESPONSIVE RENDERING VALIDATION:
? Language selection buttons: Stacked vertically ?
? All buttons: Full-width, touch-friendly (min 44px tap target) ?
? Passenger card: Full-width, stacked layout ?
? Flight card: Responsive, full-width, stacked elements ?
? Country selector: Native mobile picker ?
? Email input: Full-width, mobile keyboard with @ ?
? IDV button: Full-width, touch-friendly ?
? Persona IDV: Camera access works natively on mobile ?
? Confirmation buttons: Stacked vertically ?
? Text readability: Font size appropriate for mobile ?
? No horizontal scrolling required ?
? No truncated content ?
? No overlapping elements ?

Expected Results:
Mobile web channel detected; All UI components render responsively; Touch targets ?44px; No horizontal scrolling required; Native mobile pickers used for dropdowns; Camera access works for IDV; Full flow completed on mobile; Channel logged as "Mobile Web" 