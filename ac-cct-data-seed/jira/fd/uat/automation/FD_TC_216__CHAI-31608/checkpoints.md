# FD_TC_216 · CHAI-31608 — checkpoints

**Goal:** Validates that when a claims company is rejected on the "no claim opened" + non-EU path but disputes, the system escalates to manual handoff.

Methods: seed 4, chat 17, dashboard 6, implied 6, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Validates that when a claims company is rejected on the "no claim opened" + non-EU path but disputes, the system escalates to manual handoff |  |
| CP002 | PREREQUISITES | prerequisite | seed | Third-party caller type: Claims Company | Third-party caller type: Claims Company |
| CP003 | PREREQUISITES | prerequisite | seed | Passenger has NOT opened a claim | Passenger has NOT opened a claim |
| CP004 | PREREQUISITES | prerequisite | seed | Country of origin: US | Country of origin: US |
| CP005 | PREREQUISITES | prerequisite | seed | User disputes rejection | User disputes rejection |
| CP006 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP007 | START | bot | chat | Then the chatbot displays greeting (GLOB-01) |  |
| CP008 | START | customer | chat | Then user selects English |  |
| CP009 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP010 | START | customer | chat | And the user says "Claims company here, I need to file a disruption claim for a passenger" | Claims company here, I need to file a disruption claim for a passenger |
| CP011 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP012 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? YES |  |
| CP013 | START | system | implied | Then the chatbot identifies third-party type ? Claims Company |  |
| CP014 | CLAIM OPENED CHECK | bot | chat | Then the chatbot asks: "Has a claim been opened by the passenger?" | Has a claim been opened by the passenger? |
| CP015 | CLAIM OPENED CHECK | system | implied | And the user responds: "No" |  |
| CP016 | COUNTRY OF ORIGIN | bot | chat | Then the chatbot asks: "From which country did the person you are claiming for originate?" | From which country did the person you are claiming for originate? |
| CP017 | COUNTRY OF ORIGIN | customer | chat | And the user provides: "United States" | United States |
| CP018 | INITIAL REJECTION | bot | chat | Then the chatbot responds: "Claims for flight disruption which occurred in United States must be submitted by the passenger who experienced  | Claims for flight disruption which occurred in United States must be submitted by the passenger who experienced the disruption. Third parties cannot submit clai |
| CP019 | USER DISPUTES | system | implied | And the user responds: "We have legal authorization and insist on proceeding" |  |
| CP020 | MANUAL HANDOFF � INFO COLLECTION | bot | chat | Then the chatbot responds: "Thanks, a few questions for me to forward your claim: Please provide the name of claims company, ticket number,  | Thanks, a few questions for me to forward your claim: Please provide the name of claims company, ticket number, booking reference, contact information for the p |
| CP021 | MANUAL HANDOFF � INFO COLLECTION | customer | chat | And the user provides all required information |  |
| CP022 | CASE SENT FOR MANUAL HANDLING | system | implied | Then the system creates a case and routes it for manual handling |  |
| CP023 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything I can help you with?" | Is there anything I can help you with? |
| CP024 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP025 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP026 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the system rejects for non-EU country |  |
| CP027 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the user disputes the rejection |  |
| CP028 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the system should override and proceed to manual handoff with full info collection |  |
| CP029 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case should be created for manual handling |  |
| CP030 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claims Dashboard should show the case with dispute override noted |  |
| CP031 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And this mirrors TC187 but on the "no claim opened" branch |  |
| CP032 | PAYMENT VALIDATION | payment | chat | Given the third-party submission with no claim opened was accepted via dispute override |  |
| CP033 | PAYMENT VALIDATION | payment | chat | Then no automated payment flow should be triggered |  |
| CP034 | PAYMENT VALIDATION | payment | chat | And the case should be in manual review status |  |
