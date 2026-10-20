# FD_ED_TC_09 · CHAI-31820 — checkpoints

**Goal:** Customer booked through a travel agency (Expedia). The email on file is the agency's email, not the customer's. OTP is sent to agency email but customer doesn't have access. Customer uploads a Notice of Authorization (NOA) from the agency. Case sent for manual handling with NOA attached.

Methods: seed 1, chat 32, api 6, email 3, dashboard 3, implied 10, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Customer booked through a travel agency (Expedia). The email on file is the agency's email, not the customer's. OTP is sent to agency email  |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: TCED08 booked via travel agency (Expedia); Contact email on PNR: bookings@expedia.com (agency email); Customer's personal email: maria. | PNR: TCED08 booked via travel agency (Expedia); Contact email on PNR: bookings@expedia.com (agency email); Customer's personal email: maria.garcia@email.com; 1  |
| CP003 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP004 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP005 | START | customer | chat | Then user selects English |  |
| CP006 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP007 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP008 | START | customer | chat | And the user says "My flight from Toronto to Paris was delayed 5 hours due to a crew issue. I booked through Expedia. Can I get compensation | My flight from Toronto to Paris was delayed 5 hours due to a crew issue. I booked through Expedia. Can I get compensation? |
| CP009 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP010 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO (customer is the traveller, just booked via agency) |  |
| CP011 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP012 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP013 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP014 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP015 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Maria Garcia" | Maria Garcia |
| CP016 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Maria! And, what is your booking reference number? |
| CP017 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC227" | PNR: TC227 |
| CP018 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC227 |  |
| CP019 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP020 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data is revealed � BOOKING SOURCE: TRAVEL AGENCY (Expedia) |  |
| CP021 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer identifies: Contact email on PNR = bookings@expedia.com (agency email, NOT customer's personal email) |  |
| CP022 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP023 | AUTHENTICATION � OTP TO AGENCY EMAIL (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP024 | AUTHENTICATION � OTP TO AGENCY EMAIL (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: b***@expedia.com � Phone: (none on file) NOTE: The only email on file is the travel agency's email (bookings@expedia.com). No customer personal email o |
| CP025 | AUTHENTICATION � OTP TO AGENCY EMAIL (GenUC-05) | customer | chat | And the user selects "Email: b***@expedia.com" | Email: b***@expedia.com |
| CP026 | AUTHENTICATION � OTP TO AGENCY EMAIL (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP027 | OTP SENT TO AGENCY EMAIL � CUSTOMER CANNOT ACCESS | system | implied | And the user responds: "I don't have access to that email � that's my travel agency's email, not mine. I booked through Expedia." |  |
| CP028 | OTP ACCESS ISSUE DETECTED | bot | chat | Then the chatbot responds: | I understand. Since the email on file belongs to your travel agency, you may not have access to the verification code. Let me offer you an alternative way to ve |
| CP029 | ALTERNATIVE VERIFICATION � NOA UPLOAD PATH | bot | chat | Then the chatbot responds: | Since you booked through a travel agency, we can verify your identity if you provide a Notice of Authorization (NOA) from your travel agency. This is a document |
| CP030 | ALTERNATIVE VERIFICATION � NOA UPLOAD PATH | customer | chat | And the user selects "Yes, I have an NOA from Expedia" | Yes, I have an NOA from Expedia |
| CP031 | NOA UPLOAD | bot | chat | Then the chatbot responds: | Please upload your Notice of Authorization (NOA) from Expedia. Accepted formats: PDF, JPG, PNG (max 10MB). |
| CP032 | NOA UPLOAD | system | implied | And the user uploads: NOA_Expedia_TC227.pdf |  |
| CP033 | NOA VALIDATION | system | implied | Then the system receives the uploaded NOA document |  |
| CP034 | NOA VALIDATION | system | implied | And the system checks: | ? File format: PDF ? ? File size: 2.3 MB ? (under 10MB limit) ? Document type: NOA (Notice of Authorization) ? ? Content readable: YES ? NOTE: NOA content valid |
| CP035 | NOA VALIDATION | system | implied | Then the system determines: NOA UPLOADED � REQUIRES MANUAL VALIDATION ? CASE SENT FOR MANUAL HANDLING |  |
| CP036 | NOA UPLOADED � MANUAL HANDLING | bot | chat | Then the chatbot responds: | Thank you for uploading your Notice of Authorization. Since your booking was made through a travel agency, your claim will need to be reviewed by our team to ve |
| CP037 | ADDITIONAL CONTACT INFORMATION | bot | chat | Then the chatbot responds: | Since the email on file belongs to your travel agency, could you please provide your personal email address so we can contact you directly about your claim? |
| CP038 | ADDITIONAL CONTACT INFORMATION | customer | chat | And the user provides: "maria.garcia@email.com" | maria.garcia@email.com |
| CP039 | ADDITIONAL CONTACT INFORMATION | system | implied | Then the chatbot confirms: "Thank you. We'll use maria.garcia@email.com to contact you about your claim." |  |
| CP040 | ADDITIONAL CONTACT INFORMATION | bot | chat | And the chatbot responds: | Could you also provide a phone number where we can reach you? |
| CP041 | ADDITIONAL CONTACT INFORMATION | customer | chat | And the user provides: "+1-426-555-7890" | +1-426-555-7890 |
| CP042 | ADDITIONAL CONTACT INFORMATION | system | implied | Then the chatbot confirms: "Thank you." |  |
| CP043 | CASE CREATION � MANUAL HANDLING | system | implied | Then the system creates a case with status: PENDING MANUAL HANDLING (Travel Agency Booking + NOA Verification) |  |
| CP044 | CASE CREATION � MANUAL HANDLING | idv | chat | And the case contains: | � PNR: TC227 � Passenger: Maria Garcia � Booking Source: Travel Agency (Expedia) � Contact Email on PNR: bookings@expedia.com (agency) � Customer Personal Email |
| CP045 | CASE CREATION � MANUAL HANDLING | bot | chat | Then the chatbot responds: | Your case has been created and forwarded to our Customer Relations team. Your case reference number is [CASE-REF]. A team member will review your Notice of Auth |
| CP046 | CASE CREATION � MANUAL HANDLING | alert | chat | And an alert information is displayed: "Case created for manual review." | Case created for manual review. |
| CP047 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP048 | NOTIFICATION | email | email | And a Manual Handling notification email is sent to maria.garcia@email.com (customer's personal email) |  |
| CP049 | NOTIFICATION | email | email | And the email contains: | Your Air Canada claim has been received � [CASE-REF] Your claim has been received. Since your booking was made through a travel agency, our team will review you |
| CP050 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP051 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP052 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP053 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | When the agent navigates to Claims Dashboard |  |
| CP054 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the agent searches for the case by PNR |  |
| CP055 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the dashboard displays: | � Case Title: "Travel Disruptions � Delay (Travel Agency)" � Status: Pending Manual Handling � Created: � Last updated at � SLA � Team: Customer Relations / Tra |
| CP056 | EXPECTED RESULTS | verdict | api | Travel agency booking identified; OTP options show agency email only; Customer reports no access; NOA upload option offered; NOA document at | Travel agency booking identified; OTP options show agency email only; Customer reports no access; NOA upload option offered; NOA document attached to case; Cust |
