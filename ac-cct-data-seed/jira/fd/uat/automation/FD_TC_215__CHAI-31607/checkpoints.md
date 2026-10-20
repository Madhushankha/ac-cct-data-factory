# FD_TC_215 · CHAI-31607 — checkpoints

**Goal:** Validates that when a claims company submits, the passenger has NOT opened a claim, and the country is EU-eligible (Belgium), the system proceeds to manual handoff.

Methods: seed 3, chat 16, dashboard 7, implied 5, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Validates that when a claims company submits, the passenger has NOT opened a claim, and the country is EU-eligible (Belgium), the system pro |  |
| CP002 | PREREQUISITES | prerequisite | seed | Third-party caller type: Claims Company | Third-party caller type: Claims Company |
| CP003 | PREREQUISITES | prerequisite | seed | Passenger has NOT opened a claim | Passenger has NOT opened a claim |
| CP004 | PREREQUISITES | prerequisite | seed | Country of origin: Belgium | Country of origin: Belgium |
| CP005 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP006 | START | bot | chat | Then the chatbot displays greeting (GLOB-01) |  |
| CP007 | START | customer | chat | Then user selects English |  |
| CP008 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP009 | START | customer | chat | And the user says "I'm from a claims company, the passenger hasn't filed a claim yet but we need to submit one for a flight disruption" | I'm from a claims company, the passenger hasn't filed a claim yet but we need to submit one for a flight disruption |
| CP010 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP011 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? YES |  |
| CP012 | START | system | implied | Then the chatbot identifies third-party type ? Claims Company |  |
| CP013 | CLAIM OPENED CHECK | bot | chat | Then the chatbot asks: "Has a claim been opened by the passenger?" | Has a claim been opened by the passenger? |
| CP014 | CLAIM OPENED CHECK | system | implied | And the user responds: "No" |  |
| CP015 | COUNTRY OF ORIGIN | bot | chat | Then the chatbot asks: "From which country did the person you are claiming for originate?" | From which country did the person you are claiming for originate? |
| CP016 | COUNTRY OF ORIGIN | customer | chat | And the user provides: "Belgium" | Belgium |
| CP017 | MANUAL HANDOFF � INFO COLLECTION | bot | chat | Then the chatbot responds: "Thanks, a few questions for me to forward your claim: Please provide the name of claims company, ticket number,  | Thanks, a few questions for me to forward your claim: Please provide the name of claims company, ticket number, booking reference, contact information for the p |
| CP018 | MANUAL HANDOFF � INFO COLLECTION | customer | chat | And the user provides all required information |  |
| CP019 | CASE SENT FOR MANUAL HANDLING | system | implied | Then the system creates a case and routes it for manual handling |  |
| CP020 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything I can help you with?" | Is there anything I can help you with? |
| CP021 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP022 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP023 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the system correctly identifies the claim was NOT opened by the passenger |  |
| CP024 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system skips case number step |  |
| CP025 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the country is "Belgium" which is EU-eligible |  |
| CP026 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the manual handoff should be triggered |  |
| CP027 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And info should be collected including claims company name and ticket number and booking reference and passenger contact info and full passe |  |
| CP028 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case should be created for manual handling |  |
| CP029 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claims Dashboard should show the case routed for manual review |  |
| CP030 | PAYMENT VALIDATION | payment | chat | Given the third-party submission with no claim opened was accepted for EU-eligible country |  |
| CP031 | PAYMENT VALIDATION | payment | chat | Then no automated payment flow should be triggered |  |
| CP032 | PAYMENT VALIDATION | payment | chat | And the case should be in manual review status |  |
