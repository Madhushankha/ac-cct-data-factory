Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight was delayed 5 hours. I'd like to file a compensation claim"
When the chatbot identifies flight disruption intent
Then the chatbot checks: Is this a third-party submission? ? NO
Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation."
LEGAL DISCLAIMER:
Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need your booking reference, the name associated to the booking and any receipts you'd like to be reimbursed for. If your claim is eligible, you may also need to provide your address, contact information and where you'd like the funds deposited. Would you like to get started?"
IDENTIFICATION ATTEMPT 1 � PNR (GenUC-01):
Then the chatbot responds:
"I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you."
And the chatbot responds:
"Please provide your full name exactly as it appears on your ticket, including any middle names if applicable."
And the user provides "John Smithson"
Then the chatbot responds:
"Thanks, John! And, what is your booking reference number?"
And the user provides "PNR: XYZABC"
Then the chatbot searches Trip Tracer for PNR: XYZABC
And Trip Tracer returns: PNR NOT FOUND
Then the chatbot responds:
"I wasn't able to find a booking with that reference number. Let me try another way to locate your booking."
IDENTIFICATION ATTEMPT 2 � E-TICKET:
Then the chatbot responds:
"Can you provide your e-ticket number instead? It's a 13-digit number starting with 014 that you can find on your booking confirmation email or receipt."
And the user provides "014-9999999999"
Then the chatbot searches Trip Tracer for e-ticket: 014-9999999999
And Trip Tracer returns: E-TICKET NOT FOUND
Then the chatbot responds:
"I wasn't able to find a booking with that e-ticket number either. Let me try one more option."
IDENTIFICATION ATTEMPT 3 � AEROPLAN:
Then the chatbot responds:
"Do you have an Aeroplan number associated with your booking?"
And the user provides "9999999999"
Then the chatbot searches Trip Tracer for Aeroplan: 9999999999
And Trip Tracer returns: AEROPLAN NOT FOUND
ALL IDENTIFICATION METHODS EXHAUSTED:
Then the system determines: ALL IDENTIFICATION METHODS EXHAUSTED
? PNR: XYZABC ? NOT FOUND
? E-ticket: 014-9999999999 ? NOT FOUND
? Aeroplan: 9999999999 ? NOT FOUND
? Name: John Smithson ? NO MATCH in any system
SHELL CASE CREATION:
Then the chatbot responds:
"I'm sorry, but I wasn't able to locate your booking using the information provided. I'll create a case with the details you've shared so our Customer Relations team can assist you further. They will reach out to you to help resolve this."
Then the chatbot collects additional contact information:
"To ensure our team can reach you, could you please provide your email address and phone number?"
And the user provides:
� Email: john.smithson@email.com
� Phone: +1-555-123-4567
Then the system creates a SHELL CASE with the following information:
� Customer Name (as provided): John Smithson
� PNR Attempted: XYZABC (not found)
� E-ticket Attempted: 014-9999999999 (not found)
� Aeroplan Attempted: 9999999999 (not found)
� Contact Email: john.smithson@email.com
� Contact Phone: +1-555-123-4567
� Disruption Description: Flight delayed 5 hours
� Identification Status: ALL METHODS EXHAUSTED � NO MATCH
� Case Status: PENDING MANUAL HANDLING
And the chatbot responds:
"I've created a case for you. Our Customer Relations team will review your information and contact you within 15 business days. Your case reference number is [SHELL-CASE-REF]. Please keep this for your records."
And an alert information is displayed: "Case created for manual review."
NO AUTHENTICATION (skipped � customer not identified)
NO DDS EVALUATION (skipped � no booking identified)
NO PAYMENT FLOW (skipped)
NO IDV (skipped)
NO FRAUD SCREENING (skipped)
NOTIFICATION (Adobe):
Then the system triggers notification via Adobe:
And a Shell Case notification email is sent to john.smithson@email.com
And the email contains:
Subject: "Your Air Canada claim has been received � [SHELL-CASE-REF]"
Case Reference number
Information collected (name, attempted identifiers)
Status: "Our Customer Relations team will review your case and contact you within 15 business days."
Contact information for further questions
END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."
CLAIMS DASHBOARD VALIDATION:
When the agent navigates to Claims Dashboard
And the agent searches for the shell case
Then the dashboard displays:
� Case Title: "Travel Disruptions � Identification Failure"
� Status: Pending Manual Handling
� Created:
� Last updated at
� SLA
� Team: Customer Relations
CASE OVERVIEW
� Customer Name (as provided): John Smithson
� Identification Status: ALL METHODS EXHAUSTED
� PNR Attempted: XYZABC (NOT FOUND)
� E-ticket Attempted: 014-9999999999 (NOT FOUND)
� Aeroplan Attempted: 9999999999 (NOT FOUND)
� Contact Email: john.smithson@email.com
� Contact Phone: +1-555-123-4567
� Disruption Description: Flight delayed 5 hours
� Regime: UNKNOWN (no booking identified)

Expected Results:
All 3 identification methods attempted and failed; Shell case created with ALL collected values preserved; Customer given reference number; Contact email captured for follow-up; Case routed to manual identification queue; No authentication attempted; No DDS triggered; Full transcript preserved 