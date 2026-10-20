# FD_ED_TC_03 · CHAI-31814 — checkpoints

**Goal:** Customer cannot be identified through any method (name doesn't match, PNR not found, e-ticket not found, Aeroplan not found). System creates a shell case with whatever information was collected for tracing purposes. Validates the No Match Identification ? Manual Handling path from Miro.

Methods: seed 1, chat 26, api 7, email 3, dashboard 3, implied 5, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Customer cannot be identified through any method (name doesn't match, PNR not found, e-ticket not found, Aeroplan not found). System creates |  |
| CP002 | PREREQUISITES | prerequisite | seed | Customer provides name that doesn't match any record; PNR provided doesn't exist; No e-ticket match; No Aeroplan match | Customer provides name that doesn't match any record; PNR provided doesn't exist; No e-ticket match; No Aeroplan match |
| CP003 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP004 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP005 | START | customer | chat | Then user selects English |  |
| CP006 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP007 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP008 | START | customer | chat | And the user says "My flight was delayed 5 hours. I'd like to file a compensation claim" | My flight was delayed 5 hours. I'd like to file a compensation claim |
| CP009 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP010 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP011 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP012 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP013 | IDENTIFICATION ATTEMPT 1 � PNR (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP014 | IDENTIFICATION ATTEMPT 1 � PNR (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP015 | IDENTIFICATION ATTEMPT 1 � PNR (GenUC-01) | customer | chat | And the user provides "John Smithson" | John Smithson |
| CP016 | IDENTIFICATION ATTEMPT 1 � PNR (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, John! And, what is your booking reference number? |
| CP017 | IDENTIFICATION ATTEMPT 1 � PNR (GenUC-01) | customer | chat | And the user provides "PNR: XYZABC" | PNR: XYZABC |
| CP018 | IDENTIFICATION ATTEMPT 1 � PNR (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: XYZABC |  |
| CP019 | IDENTIFICATION ATTEMPT 1 � PNR (GenUC-01) | verdict | api | And Trip Tracer returns: PNR NOT FOUND |  |
| CP020 | IDENTIFICATION ATTEMPT 1 � PNR (GenUC-01) | bot | chat | Then the chatbot responds: | I wasn't able to find a booking with that reference number. Let me try another way to locate your booking. |
| CP021 | IDENTIFICATION ATTEMPT 2 � E-TICKET | bot | chat | Then the chatbot responds: | Can you provide your e-ticket number instead? It's a 13-digit number starting with 014 that you can find on your booking confirmation email or receipt. |
| CP022 | IDENTIFICATION ATTEMPT 2 � E-TICKET | customer | chat | And the user provides "014-9999999999" | 014-9999999999 |
| CP023 | IDENTIFICATION ATTEMPT 2 � E-TICKET | verdict | api | Then the chatbot searches Trip Tracer for e-ticket: 014-9999999999 |  |
| CP024 | IDENTIFICATION ATTEMPT 2 � E-TICKET | verdict | api | And Trip Tracer returns: E-TICKET NOT FOUND |  |
| CP025 | IDENTIFICATION ATTEMPT 2 � E-TICKET | bot | chat | Then the chatbot responds: | I wasn't able to find a booking with that e-ticket number either. Let me try one more option. |
| CP026 | IDENTIFICATION ATTEMPT 3 � AEROPLAN | bot | chat | Then the chatbot responds: | Do you have an Aeroplan number associated with your booking? |
| CP027 | IDENTIFICATION ATTEMPT 3 � AEROPLAN | customer | chat | And the user provides "9999999999" | 9999999999 |
| CP028 | IDENTIFICATION ATTEMPT 3 � AEROPLAN | verdict | api | Then the chatbot searches Trip Tracer for Aeroplan: 9999999999 |  |
| CP029 | IDENTIFICATION ATTEMPT 3 � AEROPLAN | verdict | api | And Trip Tracer returns: AEROPLAN NOT FOUND |  |
| CP030 | ALL IDENTIFICATION METHODS EXHAUSTED | system | implied | Then the system determines: ALL IDENTIFICATION METHODS EXHAUSTED | ? PNR: XYZABC ? NOT FOUND ? E-ticket: 014-9999999999 ? NOT FOUND ? Aeroplan: 9999999999 ? NOT FOUND ? Name: John Smithson ? NO MATCH in any system |
| CP031 | SHELL CASE CREATION | bot | chat | Then the chatbot responds: | I'm sorry, but I wasn't able to locate your booking using the information provided. I'll create a case with the details you've shared so our Customer Relations  |
| CP032 | SHELL CASE CREATION | system | implied | Then the chatbot collects additional contact information: | "To ensure our team can reach you, could you please provide your email address and phone number?" |
| CP033 | SHELL CASE CREATION | customer | chat | And the user provides: | � Email: john.smithson@email.com � Phone: +1-555-123-4567 |
| CP034 | SHELL CASE CREATION | system | implied | Then the system creates a SHELL CASE with the following information: | � Customer Name (as provided): John Smithson � PNR Attempted: XYZABC (not found) � E-ticket Attempted: 014-9999999999 (not found) � Aeroplan Attempted: 99999999 |
| CP035 | SHELL CASE CREATION | bot | chat | And the chatbot responds: | I've created a case for you. Our Customer Relations team will review your information and contact you within 15 business days. Your case reference number is [SH |
| CP036 | SHELL CASE CREATION | alert | chat | And an alert information is displayed: "Case created for manual review." | Case created for manual review. |
| CP037 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP038 | NOTIFICATION | email | email | And a Shell Case notification email is sent to john.smithson@email.com |  |
| CP039 | NOTIFICATION | email | email | And the email contains: | Your Air Canada claim has been received � [SHELL-CASE-REF] Our Customer Relations team will review your case and contact you within 15 business days. |
| CP040 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP041 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP042 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP043 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | When the agent navigates to Claims Dashboard |  |
| CP044 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the agent searches for the shell case |  |
| CP045 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the dashboard displays: | � Case Title: "Travel Disruptions � Identification Failure" � Status: Pending Manual Handling � Created: � Last updated at � SLA � Team: Customer Relations CASE |
| CP046 | EXPECTED RESULTS | verdict | api | All 3 identification methods attempted and failed; Shell case created with ALL collected values preserved; Customer given reference number;  | All 3 identification methods attempted and failed; Shell case created with ALL collected values preserved; Customer given reference number; Contact email captur |
