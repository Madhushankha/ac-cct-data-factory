Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "I'm a travel agent and I'd like to file a compensation claim on behalf of my client whose flight was delayed"
INTENT DETECTION � THIRD-PARTY SUBMISSION DETECTED:
When the chatbot identifies flight disruption intent
Then the chatbot checks: Is this a third-party submission? ? YES (user identified as travel agent filing on behalf of client)
THIRD-PARTY HANDOFF � IMMEDIATE:
Then the chatbot responds:
"I understand you'd like to file a claim on behalf of your client. For third-party submissions, we require a Notice of Authorization (NOA) from the passenger authorizing you to act on their behalf.
To proceed, please provide:
1
2
3
Would you like to proceed?"
And the user selects "Yes"
THIRD-PARTY INFORMATION COLLECTION:
Then the chatbot responds:
"Please provide your details as the authorized representative."
Agent Name:
And the chatbot asks: "What is your full name?"
And the user provides "Mark Johnson"
Agency Name:
And the chatbot asks: "What is the name of your travel agency?"
And the user provides "TravelCo Agency"
Agent Contact Email:
And the chatbot asks: "What is your contact email address?"
And the user provides "mark.johnson@travelco.com"
Agent Contact Phone:
And the chatbot asks: "What is your contact phone number?"
And the user provides "+1-426-555-9876"
Passenger PNR:
And the chatbot asks: "What is the passenger's booking reference number (PNR)?"
And the user provides "PNR: TC236"
Then the chatbot searches Trip Tracer for PNR: TC236
And Trip Tracer returns: PNR FOUND
And Trip Tracer identifies: Passenger = "Emma Watson"
Passenger Confirmation:
Then the chatbot responds:
"I found the booking. The passenger on this booking is Emma Watson. Is this the client you're filing on behalf of?"
And the user confirms "Yes"
NOA UPLOAD:
Then the chatbot responds:
"Please upload the Notice of Authorization (NOA) signed by Emma Watson, authorizing you (Mark Johnson / TravelCo Agency) to file a claim on her behalf. Accepted formats: PDF, JPG, PNG (max 10MB)."
And the user uploads: NOA_EmmaWatson_TravelCo.pdf
NOA VALIDATION (System):
Then the system receives the uploaded NOA document
And the system checks:
? File format: PDF ?
? File size: 1.8 MB ? (under 10MB limit)
? Document type: NOA (Notice of Authorization) ?
? Content readable: YES ?
NOTE: NOA content validation (verifying passenger signature, matching PNR, matching agent details) is done MANUALLY by an agent � the system cannot auto-validate NOA content.
CASE CREATION � THIRD-PARTY MANUAL HANDLING:
Then the system creates a case with status: PENDING MANUAL HANDLING (Third-Party Submission)
And the case contains:
� PNR: TC236
� Passenger: Emma Watson
� Claimant Type: THIRD-PARTY (Travel Agent)
� Agent Name: Mark Johnson
� Agency: TravelCo Agency
� Agent Email: mark.johnson@travelco.com
� Agent Phone: +1-426-555-9876
� NOA Document: NOA_EmmaWatson_TravelCo.pdf (attached)
� Authentication Status: PENDING (third-party � requires manual NOA verification)
� Case Status: Pending Manual Handling
� Routing: Customer Relations / Third-Party Verification Team
Then the chatbot responds:
"Thank you, Mark. Your claim on behalf of Emma Watson has been received. Our Customer Relations team will review the Notice of Authorization and process the claim. You will receive updates at mark.johnson@travelco.com.
Your case reference number is [CASE-REF]. Please allow up to 15 business days for processing."
And an alert information is displayed: "Third-party claim received for manual review."
NO AUTHENTICATION (skipped � third-party submission, manual handling)
NO DDS EVALUATION (deferred � third-party, requires NOA verification first)
NO PAYMENT FLOW (deferred � third-party, requires NOA verification first)
NO FRAUD SCREENING (deferred)
NOTIFICATION (Adobe):
Then the system triggers notification via Adobe:
And a Third-Party Claim notification email is sent to mark.johnson@travelco.com (agent email)
And the email contains:
Subject: "Third-party claim received � [CASE-REF]"
Case Reference number
Passenger: Emma Watson
PNR: TC236
Agent: Mark Johnson / TravelCo Agency
NOA: Received and attached to case
Status: "Your claim is under review. Our team will verify the Notice of Authorization and process the claim."
Expected timeline: 15 business days
Contact information
AND a separate notification is sent to the passenger (Emma Watson) at her email on file:
Subject: "A claim has been filed on your behalf � [CASE-REF]"
Case Reference number
Agent: Mark Johnson / TravelCo Agency
Status: "A travel agent has filed a flight disruption claim on your behalf. If you did not authorize this, please contact us immediately."
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
� Case Title: "Travel Disruptions � Third-Party Claim"
� Status: Pending Manual Handling
� Created:
� Last updated at
� SLA
� Team: Customer Relations / Third-Party Verification
CASE OVERVIEW
� Passenger Name: Emma Watson
� Claimant Type: THIRD-PARTY (Travel Agent)
� Agent Name: Mark Johnson
� Agency: TravelCo Agency
� Agent Email: mark.johnson@travelco.com
� Agent Phone: +1-426-555-9876
� Authentication Status: PENDING (NOA uploaded, awaiting manual verification)
� PNR: TC236
ATTACHMENTS
� NOA_EmmaWatson_TravelCo.pdf
ELIGIBILITY AND COMPENSATION
� Status: PENDING (third-party � NOA verification required)
THIRD-PARTY VALIDATION:
? Third-party detected at first check: YES ?
? Agent details collected: YES ?
? NOA uploaded: YES ?
? Passenger notified of third-party claim: YES ?
? Standard flow bypassed (no OTP, no DDS, no payment): YES ?
? Case routed to manual handling: YES ?

Expected Results:
Third-party submission detected at first check; Agent details collected; NOA uploaded and attached; Case routed to manual third-party verification; Dashboard shows submission type, agent details, and NOA; DDS not triggered until verification complete