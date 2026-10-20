Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight from Toronto to Paris was delayed 5 hours due to a crew issue. I booked through Expedia. Can I get compensation?"
When the chatbot identifies flight disruption intent
Then the chatbot checks: Is this a third-party submission? ? NO (customer is the traveller, just booked via agency)
Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation."
LEGAL DISCLAIMER:
Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need your booking reference, the name associated to the booking and any receipts you'd like to be reimbursed for. If your claim is eligible, you may also need to provide your address, contact information and where you'd like the funds deposited. Would you like to get started?"
IDENTIFICATION (GenUC-01):
Then the chatbot responds:
"I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you."
And the chatbot responds:
"Please provide your full name exactly as it appears on your ticket, including any middle names if applicable."
And the user provides "Maria Garcia"
Then the chatbot responds:
"Thanks, Maria! And, what is your booking reference number?"
And the user provides "PNR: TC227"
Then the chatbot searches Trip Tracer for PNR: TC227
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data is revealed � BOOKING SOURCE: TRAVEL AGENCY (Expedia)
And Trip Tracer identifies: Contact email on PNR = bookings@expedia.com (agency email, NOT customer's personal email)
And Trip Tracer data (passenger info, journey details) is revealed to the customer
AUTHENTICATION (GenUC-05) � OTP TO AGENCY EMAIL:
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
� Email: b***@expedia.com
� Phone: (none on file)
NOTE: The only email on file is the travel agency's email (bookings@expedia.com). No customer personal email or phone is on the PNR.
And the user selects "Email: b***@expedia.com"
Then the chatbot responds:
"I've sent a verification code to your email, please enter it within 15 minutes of receiving it."
OTP SENT TO AGENCY EMAIL � CUSTOMER CANNOT ACCESS:
And the user responds: "I don't have access to that email � that's my travel agency's email, not mine. I booked through Expedia."
OTP ACCESS ISSUE DETECTED:
Then the chatbot responds:
"I understand. Since the email on file belongs to your travel agency, you may not have access to the verification code. Let me offer you an alternative way to verify your identity."
ALTERNATIVE VERIFICATION � NOA UPLOAD PATH:
Then the chatbot responds:
"Since you booked through a travel agency, we can verify your identity if you provide a Notice of Authorization (NOA) from your travel agency. This is a document from Expedia confirming that you are the authorized traveller on this booking. You can also provide:
� A copy of your government-issued photo ID
� Your booking confirmation from Expedia showing your name
Would you like to upload these documents?"
And the user selects "Yes, I have an NOA from Expedia"
NOA UPLOAD:
Then the chatbot responds:
"Please upload your Notice of Authorization (NOA) from Expedia. Accepted formats: PDF, JPG, PNG (max 10MB)."
And the user uploads: NOA_Expedia_TC227.pdf
NOA VALIDATION (System):
Then the system receives the uploaded NOA document
And the system checks:
? File format: PDF ?
? File size: 2.3 MB ? (under 10MB limit)
? Document type: NOA (Notice of Authorization) ?
? Content readable: YES ?
NOTE: NOA content validation (verifying agency letterhead, matching PNR, matching passenger name) is done MANUALLY by an agent � the system cannot auto-validate NOA content.
Then the system determines: NOA UPLOADED � REQUIRES MANUAL VALIDATION ? CASE SENT FOR MANUAL HANDLING
NOA UPLOADED � MANUAL HANDLING:
Then the chatbot responds:
"Thank you for uploading your Notice of Authorization. Since your booking was made through a travel agency, your claim will need to be reviewed by our team to verify the authorization. I'll create a case with all the information you've provided, including the NOA document."
ADDITIONAL CONTACT INFORMATION:
Then the chatbot responds:
"Since the email on file belongs to your travel agency, could you please provide your personal email address so we can contact you directly about your claim?"
And the user provides: "maria.garcia@email.com"
Then the chatbot confirms: "Thank you. We'll use maria.garcia@email.com to contact you about your claim."
And the chatbot responds:
"Could you also provide a phone number where we can reach you?"
And the user provides: "+1-426-555-7890"
Then the chatbot confirms: "Thank you."
CASE CREATION � MANUAL HANDLING (Travel Agency + NOA):
Then the system creates a case with status: PENDING MANUAL HANDLING (Travel Agency Booking + NOA Verification)
And the case contains:
� PNR: TC227
� Passenger: Maria Garcia
� Booking Source: Travel Agency (Expedia)
� Contact Email on PNR: bookings@expedia.com (agency)
� Customer Personal Email: maria.garcia@email.com (provided by customer)
� Customer Phone: +1-426-555-7890 (provided by customer)
� Journey: YYZ?CDG, delayed 5h
� Authentication Status: PENDING (OTP not completed � agency email; NOA uploaded for manual verification)
� NOA Document: NOA_Expedia_TC227.pdf (attached)
� Case Status: Pending Manual Handling
� Routing: Customer Relations / Travel Agency Verification Team
Then the chatbot responds:
"Your case has been created and forwarded to our Customer Relations team. Your case reference number is [CASE-REF]. A team member will review your Notice of Authorization and contact you at maria.garcia@email.com within 15 business days to process your claim."
And an alert information is displayed: "Case created for manual review."
NO DDS EVALUATION (deferred � authentication not completed)
NO PAYMENT FLOW (deferred � authentication not completed)
NO FRAUD SCREENING (deferred)
NOTIFICATION (Adobe):
Then the system triggers notification via Adobe:
And a Manual Handling notification email is sent to maria.garcia@email.com (customer's personal email)
And the email contains:
Subject: "Your Air Canada claim has been received � [CASE-REF]"
Case Reference number
Flight details (YYZ?CDG, delayed 5h)
Status: "Your claim has been received. Since your booking was made through a travel agency, our team will review your Notice of Authorization and process your claim."
NOA: Received and attached to case
Expected timeline: 15 business days
Contact information for further questions
AND a copy notification is NOT sent to bookings@expedia.com (agency email � customer communications go to personal email only)
END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."
CLAIMS DASHBOARD VALIDATION:
When the agent navigates to Claims Dashboard
And the agent searches for the case by PNR
Then the dashboard displays:
� Case Title: "Travel Disruptions � Delay (Travel Agency)"
� Status: Pending Manual Handling
� Created:
� Last updated at
� SLA
� Team: Customer Relations / Travel Agency Verification
CASE OVERVIEW
� Claimant Name: Maria Garcia
� Claimant Type: Passenger (booked via travel agency)
� Booking Source: Travel Agency (Expedia)
� Authentication Status: PENDING (NOA uploaded, awaiting manual verification)
� OTP: NOT COMPLETED (agency email � customer no access)
� NOA: UPLOADED (NOA_Expedia_TC227.pdf)
� PNR: TC227
� PNR Contact Email: bookings@expedia.com (agency)
� Customer Personal Email: maria.garcia@email.com
� Customer Phone: +1-426-555-7890
� Journey: YYZ ? CDG (DELAYED +5h)
� Regime: EU 261 (pending � not yet assessed)
� Eligibility: PENDING (authentication required first)
PASSENGER INFORMATION
� Full Name: Maria Garcia
� Tags: Claimant, Adult, Travel Agency Booking
� Email: maria.garcia@email.com (personal)
� Phone: +1-426-555-7890
ITINERARY
� Journey: Bound 1: YYZ ? CDG (DELAYED +5h) (Claim filed for this flight)
ATTACHMENTS
� NOA_Expedia_TC227.pdf (Notice of Authorization from Expedia)
ANCILLARY FEE
ELIGIBILITY AND COMPENSATION
� Status: PENDING (authentication required � NOA manual verification)

Expected Results:
Travel agency booking identified; OTP options show agency email only; Customer reports no access; NOA upload option offered; NOA document attached to case; Customer's personal contact info captured; Case routed to manual NOA verification; DDS not triggered until auth resolved