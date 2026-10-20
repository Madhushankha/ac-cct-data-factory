BACKGROUND � ORIGINAL CASE (Previously Completed):
Given a case was previously created: CASE-FD-20260520-060
And the case details are:
? Passenger: Claire Dubois (Basic Aeroplan Member #: 9876543210)
? PNR: TC239
? Journey: YUL ? YYZ (AC 301), May 20, 2026, delayed 7h (6�<9h band)
? Scheduled Arrival: 14:00 ? Actual Arrival: 21:00
? Disruption Code: 64 (Flight Crew Shortage � Controllable)
? Regime: APPR (domestic)
? Decision: ELIGIBLE ($700 CAD Cash Tier 2 / $840 CAD AC Wallet offered; customer selected Cash)
? Payment Method: Interac e-Transfer ($700 CAD)
? Payment Email: claire.dubois@gmail.com
? IDV: PASS
? CyberSource: GREEN
? Case Status: Eligible � Payment Initiated

PAYMENT FAILURE (Backend � No Customer Interaction):
When the system initiates Interac e-Transfer of $700 CAD to claire.dubois@gmail.com
Then the payment processor attempts the transfer
And the bank returns: PAYMENT REJECTED
? Rejection Reason: ACCOUNT CLOSED (the email is no longer linked to an active Interac account)
? Error Code: BANK_REJECT_ACCOUNT_CLOSED
? Payment Status: FAILED
? Retry Attempted: YES (automatic retry after 24 hours)
? Retry Result: FAILED AGAIN (same rejection)

PAYMENT FAILURE NOTIFICATION (Adobe):
Then the system triggers notification via Adobe:
And a Payment Failed notification email is sent to claire.dubois@gmail.com
And the email contains:
Subject: "Action Required: Payment for your Air Canada claim � CASE-FD-20260520-060"
� Case Reference: CASE-FD-20260520-060
� Flight Details: YUL ? YYZ, May 20, 2026, 7h delay (Flight Crew Shortage � Code 64)
� Payment Amount: $700 CAD
� Payment Method: Interac e-Transfer
� Status: Payment could not be processed
� Reason: "We were unable to complete the payment to the email address provided. This may be due to an issue with your Interac e-Transfer registration."
� Action Required: "Please return to our chatbot to update your payment details so we can re-process your compensation."
� Link to chatbot
� Contact information for further questions

CASE STATUS UPDATE (Backend):
Then the system updates the case status:
? Previous Status: Eligible � Payment Initiated
? New Status: Eligible � Payment Failed (Awaiting Updated Banking Details)
? Payment Failure Reason: Bank rejection � account closed
? Payment Retry Count: 2 (initial + 1 retry, both failed)

CUSTOMER RETURNS TO CHATBOT:
Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "I received an email saying my payment failed for my compensation claim. I need to update my banking details."

INTENT DETECTION � PAYMENT UPDATE:
When the chatbot identifies payment update intent
Then the chatbot responds:
"I can help you update your payment details. Let me look up your case first."

CASE LOOKUP:
Then the chatbot responds:
"Could you please provide your case reference number or booking reference (PNR)?"
And the user provides "CASE-FD-20260520-060"

CASE RETRIEVAL:
Then the system searches Case Services for: CASE-FD-20260520-060
And Case Services returns: CASE FOUND
? Case Reference: CASE-FD-20260520-060
? Passenger: Claire Dubois (Aeroplan Basic Member #: 9876543210)
? Journey: YUL ? YYZ, 7h delay (Code 64 Crew Shortage)
? Status: Eligible � Payment Failed
? Compensation: $700 CAD
? Payment Failure Reason: Bank rejection � account closed

IDENTITY RE-VERIFICATION:
Then the chatbot responds:
"I found your case. Before we update your payment details, I need to verify your identity."
And the chatbot displays options:
� Email: c***@gmail.com
� Phone: +1***567
And the user selects "Email: c***@gmail.com"
Then the chatbot responds:
"I've sent a verification code to your email, please enter it within 15 minutes of receiving it."
And the user provides the OTP code "518293"
Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5)
Then the chatbot responds:
"Your verification was successful."

PAYMENT FAILURE EXPLANATION:
Then the chatbot responds:
"I can see that the payment of $700 CAD for your claim could not be processed. The Interac e-Transfer to your previous email address was unsuccessful. Let's update your payment details so we can re-process the payment.
Would you like to:
� Update your Interac e-Transfer email � provide a different email address
� Switch to a different payment method � if you'd prefer another option

Which would you prefer?"
And the user selects "Update my Interac e-Transfer email"

UPDATED PAYMENT DETAILS:
Then the chatbot responds:
"Please provide the new email address where you'd like to receive the Interac e-Transfer."
And the user provides "claire.dubois.new@gmail.com"
Then the chatbot confirms:
"Thank you. I'll update your payment details to:
� Payment Method: Interac e-Transfer
� New Email: claire.dubois.new@gmail.com
� Amount: $700 CAD

Would you like me to re-process the payment?"
And the user confirms "Yes"

IDV CHECK � ALREADY COMPLETED:
Then the system checks: Has IDV been completed for this case? ? YES (completed during original submission)
Then the system determines: IDV ALREADY PASSED � NO NEED TO REPEAT

PAYMENT RE-PROCESSING:
Then the system updates the case:
? Payment Email: claire.dubois@gmail.com ? claire.dubois.new@gmail.com
? Payment Status: Failed ? Re-Processing
? Re-Processing Initiated: June 15, 2026
Then the chatbot responds:
"Your payment details have been updated and the payment is being re-processed. You should receive the $700 CAD via Interac e-Transfer at claire.dubois.new@gmail.com within 5 to 10 business days."
And an alert information is displayed: "Payment re-processing initiated!"

NOTIFICATION � PAYMENT RE-PROCESSING (Adobe):
Then the system triggers notification via Adobe:
And a Payment Re-Processing notification email is sent to claire.dubois.new@gmail.com
And the email contains:
Subject: "Payment re-processing for your Air Canada claim � CASE-FD-20260520-060"
� Case Reference: CASE-FD-20260520-060
� Flight Details: YUL ? YYZ, May 20, 2026, 7h delay (Flight Crew Shortage � Code 64)
� Payment Amount: $700 CAD
� Updated Payment Method: Interac e-Transfer to claire.dubois.new@gmail.com
� Status: "Your payment is being re-processed. Please allow 5 to 10 business days."
� Contact information

END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION:
When the agent navigates to Claims Dashboard
And the agent searches for the case
Then the dashboard displays:
� Case Reference: CASE-FD-20260520-060
� Claimant Name: Claire Dubois
� Aeroplan: 9876543210 (linked, Basic Member in good standing)
� Status: Eligible � Payment Re-Processing
� Disruption Code: Code 64 (Flight Crew Shortage � Controllable)
� Arrival Delay: 7 hours (6�<9h band, APPR Tier 2)
� Compensation: $700 CAD
� Payment History:
  Attempt 1: Interac $700 CAD to claire.dubois@gmail.com ? FAILED (account closed)
  Retry 1: Interac $700 CAD to claire.dubois@gmail.com ? FAILED (account closed)
  Attempt 3: Interac $700 CAD to claire.dubois.new@gmail.com ? RE-PROCESSING
� Payment Email Updated: June 15, 2026
� IDV: PASS (original � not repeated)
� CyberSource: GREEN (original)