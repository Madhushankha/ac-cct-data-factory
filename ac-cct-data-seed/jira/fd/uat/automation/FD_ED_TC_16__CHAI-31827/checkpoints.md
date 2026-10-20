# FD_ED_TC_16 · CHAI-31827 — checkpoints

**Goal:** A travel agent (not the passenger) submits a claim on behalf of their client. System detects third-party submission at the very first check and requires Notice of Authorization (NOA). Tests the Third Party Handoff flow from Miro.

Methods: seed 1, chat 27, api 4, email 3, dashboard 3, implied 8, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | A travel agent (not the passenger) submits a claim on behalf of their client. System detects third-party submission at the very first check  |  |
| CP002 | PREREQUISITES | prerequisite | seed | Claimant is a travel agent (NOT the passenger); Passenger: "Emma Watson" on PNR TCED16; Agent: "Mark Johnson" from "TravelCo Agency" | Claimant is a travel agent (NOT the passenger); Passenger: "Emma Watson" on PNR TCED16; Agent: "Mark Johnson" from "TravelCo Agency" |
| CP003 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP004 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP005 | START | customer | chat | Then user selects English |  |
| CP006 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP007 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP008 | START | customer | chat | And the user says "I'm a travel agent and I'd like to file a compensation claim on behalf of my client whose flight was delayed" | I'm a travel agent and I'd like to file a compensation claim on behalf of my client whose flight was delayed |
| CP009 | INTENT DETECTION � THIRD-PARTY SUBMISSION DETECTED | system | implied | When the chatbot identifies flight disruption intent |  |
| CP010 | INTENT DETECTION � THIRD-PARTY SUBMISSION DETECTED | system | implied | Then the chatbot checks: Is this a third-party submission? ? YES (user identified as travel agent filing on behalf of client) |  |
| CP011 | THIRD-PARTY HANDOFF � IMMEDIATE | bot | chat | Then the chatbot responds: | I understand you'd like to file a claim on behalf of your client. For third-party submissions, we require a Notice of Authorization (NOA) from the passenger aut |
| CP012 | THIRD-PARTY HANDOFF � IMMEDIATE | customer | chat | And the user selects "Yes" | Yes |
| CP013 | THIRD-PARTY INFORMATION COLLECTION | bot | chat | Then the chatbot responds: | Please provide your details as the authorized representative. |
| CP014 | THIRD-PARTY INFORMATION COLLECTION | bot | chat | And the chatbot asks: "What is your full name?" | What is your full name? |
| CP015 | THIRD-PARTY INFORMATION COLLECTION | customer | chat | And the user provides "Mark Johnson" | Mark Johnson |
| CP016 | THIRD-PARTY INFORMATION COLLECTION | bot | chat | And the chatbot asks: "What is the name of your travel agency?" | What is the name of your travel agency? |
| CP017 | THIRD-PARTY INFORMATION COLLECTION | customer | chat | And the user provides "TravelCo Agency" | TravelCo Agency |
| CP018 | THIRD-PARTY INFORMATION COLLECTION | bot | chat | And the chatbot asks: "What is your contact email address?" | What is your contact email address? |
| CP019 | THIRD-PARTY INFORMATION COLLECTION | customer | chat | And the user provides "mark.johnson@travelco.com" | mark.johnson@travelco.com |
| CP020 | THIRD-PARTY INFORMATION COLLECTION | bot | chat | And the chatbot asks: "What is your contact phone number?" | What is your contact phone number? |
| CP021 | THIRD-PARTY INFORMATION COLLECTION | customer | chat | And the user provides "+1-426-555-9876" | +1-426-555-9876 |
| CP022 | THIRD-PARTY INFORMATION COLLECTION | bot | chat | And the chatbot asks: "What is the passenger's booking reference number (PNR)?" | What is the passenger's booking reference number (PNR)? |
| CP023 | THIRD-PARTY INFORMATION COLLECTION | customer | chat | And the user provides "PNR: TC236" | PNR: TC236 |
| CP024 | THIRD-PARTY INFORMATION COLLECTION | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC236 |  |
| CP025 | THIRD-PARTY INFORMATION COLLECTION | verdict | api | And Trip Tracer returns: PNR FOUND |  |
| CP026 | THIRD-PARTY INFORMATION COLLECTION | verdict | api | And Trip Tracer identifies: Passenger = "Emma Watson" | Emma Watson |
| CP027 | THIRD-PARTY INFORMATION COLLECTION | bot | chat | Then the chatbot responds: | I found the booking. The passenger on this booking is Emma Watson. Is this the client you're filing on behalf of? |
| CP028 | THIRD-PARTY INFORMATION COLLECTION | customer | chat | And the user confirms "Yes" | Yes |
| CP029 | NOA UPLOAD | bot | chat | Then the chatbot responds: | Please upload the Notice of Authorization (NOA) signed by Emma Watson, authorizing you (Mark Johnson / TravelCo Agency) to file a claim on her behalf. Accepted  |
| CP030 | NOA UPLOAD | system | implied | And the user uploads: NOA_EmmaWatson_TravelCo.pdf |  |
| CP031 | NOA VALIDATION | system | implied | Then the system receives the uploaded NOA document |  |
| CP032 | NOA VALIDATION | system | implied | And the system checks: | ? File format: PDF ? ? File size: 1.8 MB ? (under 10MB limit) ? Document type: NOA (Notice of Authorization) ? ? Content readable: YES ? NOTE: NOA content valid |
| CP033 | CASE CREATION � THIRD-PARTY MANUAL HANDLING | system | implied | Then the system creates a case with status: PENDING MANUAL HANDLING (Third-Party Submission) |  |
| CP034 | CASE CREATION � THIRD-PARTY MANUAL HANDLING | system | implied | And the case contains: | � PNR: TC236 � Passenger: Emma Watson � Claimant Type: THIRD-PARTY (Travel Agent) � Agent Name: Mark Johnson � Agency: TravelCo Agency � Agent Email: mark.johns |
| CP035 | CASE CREATION � THIRD-PARTY MANUAL HANDLING | bot | chat | Then the chatbot responds: | Thank you, Mark. Your claim on behalf of Emma Watson has been received. Our Customer Relations team will review the Notice of Authorization and process the clai |
| CP036 | CASE CREATION � THIRD-PARTY MANUAL HANDLING | alert | chat | And an alert information is displayed: "Third-party claim received for manual review." | Third-party claim received for manual review. |
| CP037 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP038 | NOTIFICATION | email | email | And a Third-Party Claim notification email is sent to mark.johnson@travelco.com (agent email) |  |
| CP039 | NOTIFICATION | email | email | And the email contains: | Third-party claim received � [CASE-REF] Your claim is under review. Our team will verify the Notice of Authorization and process the claim. A claim has been fil |
| CP040 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP041 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP042 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP043 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | When the agent navigates to Claims Dashboard |  |
| CP044 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the agent searches for the case by PNR |  |
| CP045 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the dashboard displays: | � Case Title: "Travel Disruptions � Third-Party Claim" � Status: Pending Manual Handling � Created: � Last updated at � SLA � Team: Customer Relations / Third-P |
| CP046 | THIRD-PARTY VALIDATION | system | implied | ? Third-party detected at first check: YES ? | ? Agent details collected: YES ? ? NOA uploaded: YES ? ? Passenger notified of third-party claim: YES ? ? Standard flow bypassed (no OTP, no DDS, no payment): Y |
| CP047 | EXPECTED RESULTS | verdict | api | Third-party submission detected at first check; Agent details collected; NOA uploaded and attached; Case routed to manual third-party verifi | Third-party submission detected at first check; Agent details collected; NOA uploaded and attached; Case routed to manual third-party verification; Dashboard sh |
