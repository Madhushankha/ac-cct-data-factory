Given the user opens the agentic chatbot via WhatsApp (not web, not mobile app)
Then the system detects: Channel = WhatsApp
And the system applies: WhatsApp rendering rules (text-based fallbacks for rich UI components)
Then the chatbot displays greeting (GLOB-01) � WhatsApp text format:
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?
Reply with:
1 - English
2 - French"
NOTE: On web/mobile, this would be interactive buttons. On WhatsApp, it falls back to numbered text options.
Then user replies "1"
Then the chatbot sends a text message: "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight from Montreal to Toronto was delayed 4 hours due to a crew issue. I'd like to check if I'm eligible for compensation"
When the chatbot identifies flight disruption intent
Then the chatbot checks: Is this a third-party submission? ? NO
Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation."
LEGAL DISCLAIMER (WhatsApp text format):
Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need your booking reference, the name associated to the booking and any receipts you'd like to be reimbursed for. If your claim is eligible, you may also need to provide your address, contact information and where you'd like the funds deposited. Would you like to get started?
Reply with:
1 - Yes
2 - No"
And the user replies "1"
IDENTIFICATION (GenUC-01) � WhatsApp:
Then the chatbot responds:
"I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you."
And the chatbot responds:
"Please provide your full name exactly as it appears on your ticket, including any middle names if applicable."
And the user provides "Olivier Bergeron"
Then the chatbot responds:
"Thanks, Olivier! And, what is your booking reference number?"
And the user provides "TC243"
Then the chatbot searches Trip Tracer for PNR: TC243
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer
AUTHENTICATION (GenUC-05) � WhatsApp:
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?
Reply with:
1 - Email: o***@gmail.com
2 - Phone: +1***234"
NOTE: On web/mobile, these would be clickable buttons. On WhatsApp, numbered text options.
And the user replies "1"
Then the chatbot responds:
"I've sent a verification code to your email, please enter it within 15 minutes of receiving it."
And the user provides the OTP code "518293"
Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5)
Then the chatbot responds:
"Your verification was successful. Let's proceed to the next step."
GROUP BOOKING CHECK:
Then the system checks Trip Tracer for group booking identifier
And group booking identifier = NOT PRESENT
And system proceeds to passenger selection
PASSENGER SELECTION (GenUC-06) � WhatsApp:
Then the chatbot responds:
"How many people are on your claim?
I found 1 passenger on this booking:
Olivier Bergeron (Adult)
Is this who you'd like to include?
Reply with:
1 - Yes
2 - No"
NOTE: On web/mobile, this would be a passenger card with checkboxes. On WhatsApp, text list with numbered confirmation.
And the user replies "1"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED
JOURNEY SELECTION (GenUC-08) � WhatsApp (FLIGHT CARD FALLBACK):
Then the chatbot retrieves booking details and displays in text format (no flight card rendering on WhatsApp):
"I found the following journey:
Flight: AC 422
Route: Montreal (YUL) ? Toronto (YYZ)
Date: June 1, 2026
Arrival Delay: 4 hours
Is this the journey you'd like to check?
Reply with:
1 - Yes
2 - No"
NOTE: On web/mobile, this would render as an interactive flight card with visual elements (airline logo, route map, status badge). On WhatsApp, it falls back to plain text with the same information.
And the user replies "1"
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
Then the system determines: Origin = YUL (Canada) ? APPR
And the system checks: Distance YUL?YYZ = ~505 km ? Short-haul
TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS Evaluates:
APPR: Delay 3�6h, Controllable ? ELIGIBLE
Compensation: CAD $400
FRAUD SCREENING � CYBERSOURCE (GLOB-05):
Then the chatbot sends case details to CyberSource for fraud screening
And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected)
And the customer is cleared to proceed to payment
ELIGIBLE RESULT (FD-05a) � WhatsApp:
Then the chatbot displays (text format):
"I've checked your flight details, and it looks like flight AC 422 from Montreal (YUL) to Toronto (YYZ) was delayed by about 4 hours. Based on the Canadian Air Passenger Protection Regulations (APPR), you may be eligible for compensation of $400 CAD for this delay. I'll guide you through the next steps so we can get your claim submitted and processed as quickly as possible."
CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW � WhatsApp:
Then the chatbot asks:
"Thank you for confirming. In which country will your reimbursement be deposited?
Reply with:
1 - Canada
2 - United States
3 - Other (please type your country)"
NOTE: On web/mobile, this would be a dropdown/searchable country selector. On WhatsApp, common countries listed with numbered options + free-text for others.
And the user replies "1"
Then the system determines: Country = Canada ? Currency = CAD
CASH vs AC WALLET CHECK (FD-06b):
Then the chatbot checks: Does customer have Aeroplan number on booking? ? No
Then the chatbot checks if the claim is for multiple pax ? No
Then the chatbot responds: "You are entitled to receive a $400 CAD compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed?
Reply with:
1 - Yes
2 - No"
And an alert information is displayed (text): "Please note that payments will be deposited in your local currency."
And user replies "1"
Then system checks which payment method is mapped based on country of residence ? Interac e-Transfer (Canada)
PAYMENT METHOD � INTERAC E-TRANSFER (FD-07) � WhatsApp:
Then the chatbot responds:
"Your payment will be made through Interac e-Transfer. Before we move forward, please provide the email address where you'd like to receive the transfer."
And the user provides "olivier.bergeron@gmail.com"
Then the chatbot confirms: "Thank you. Your Interac e-Transfer details have been recorded."
Then system checks that IDV is not completed
IDENTITY VERIFICATION � PERSONA (FD-07b) � WhatsApp:
Then the chatbot responds:
"I must verify your identity for payment security. Please click the link below to get started:
[Persona Verification Link]
Open this link in your mobile browser to complete the verification."
NOTE: On web/mobile, this would be an embedded button "Get verified". On WhatsApp, it's a clickable URL link since WhatsApp doesn't support embedded buttons in the same way.
When user clicks on the link
Then the user is redirected to Persona IDV in their mobile browser
And the customer completes identity verification via Persona
And Persona returns: IDV PASS
Then the chatbot responds (back in WhatsApp):
"Your identity has been verified successfully. Let's proceed to finalize your claim."
CLAIM AMOUNT CONFIRMATION FLOW � WhatsApp:
Then the chatbot responds: "Please review your compensation details:
Deposit Amount: $400 CAD
Payment Method: Interac e-Transfer
After submission, you will receive a confirmation email summarizing your eligibility, claim details and next steps.
Would you like me to submit your claim?
Reply with:
1 - Yes, submit
2 - No, cancel
Please note that the payment details cannot be changed after submission."
When the user replies "1"
CASE CREATION (GLOB-09):
Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your claim details, and a second email that will include the secure link where you'll provide your information."
And the chatbot sends: "Claim submission successful!"
And the system appends the booking record to the case automatically
NOTIFICATION (Adobe):
Then the system triggers notification via Adobe:
And an eligible notification email is sent to o***@gmail.com
And the email contains: Case Reference, compensation amount ($400 CAD), regulation (APPR), flight details, channel (WhatsApp), next steps, tracking link
END FLOW (GLOB-11) � WhatsApp:
Then the chatbot offers:
"Is there anything I can help you with?
Reply with:
1 - Yes, I have another request
2 - No, I'm done"
And the user replies "2"
Then the chatbot responds "Thank you for choosing Air Canada."
WHATSAPP COMPONENT RENDERING VALIDATION:
? Language selection: Numbered text options (not buttons) ?
? Legal disclaimer confirmation: Numbered text options ?
? OTP delivery selection: Numbered text options ?
? Passenger selection: Text list with numbered confirmation ?
? Flight card: Plain text format (no visual card) ?
? Journey confirmation: Numbered text options ?
? Country selection: Numbered text + free-text fallback ?
? Payment confirmation: Numbered text options ?
? IDV link: Clickable URL (not embedded button) ?
? Claim submission: Numbered text options ?
? End flow: Numbered text options ?
? All information conveyed accurately despite text-only format ?
? No rendering errors or broken components ?
CLAIMS DASHBOARD VALIDATION:
When the agent navigates to Claims Dashboard
And the agent searches for the case by PNR
Then the dashboard displays:
� Case Title: "Travel Disruptions � Delay"
� Status: in review/done
� Channel: WhatsApp
� Rendering Mode: Text Fallback
� Regime: APPR

Expected Results:
WhatsApp channel detected; All rich UI components (cards, buttons, dropdowns) replaced with text-based alternatives; Numbered options used instead of buttons; Flight details displayed as text instead of flight card; Full flow completed successfully via text; Channel logged as WhatsApp in dashboard