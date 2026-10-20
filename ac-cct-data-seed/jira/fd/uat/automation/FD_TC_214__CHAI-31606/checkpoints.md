# FD_TC_214 · CHAI-31606 — checkpoints

**Goal:** Validates that when a claims company submits and the passenger has NOT opened a claim, and the country is non-EU, the system rejects the submission.

Methods: seed 3, chat 14, dashboard 6, implied 4, manual 1, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Validates that when a claims company submits and the passenger has NOT opened a claim, and the country is non-EU, the system rejects the sub |  |
| CP002 | PREREQUISITES | prerequisite | seed | Third-party caller type: Claims Company | Third-party caller type: Claims Company |
| CP003 | PREREQUISITES | prerequisite | seed | Passenger has NOT opened a claim | Passenger has NOT opened a claim |
| CP004 | PREREQUISITES | prerequisite | seed | Country of origin: Canada | Country of origin: Canada |
| CP005 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP006 | START | bot | chat | Then the chatbot displays greeting (GLOB-01) |  |
| CP007 | START | customer | chat | Then user selects English |  |
| CP008 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP009 | START | customer | chat | And the user says "I'm a claims company and I want to submit a flight disruption claim for a passenger" | I'm a claims company and I want to submit a flight disruption claim for a passenger |
| CP010 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP011 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? YES |  |
| CP012 | START | system | implied | Then the chatbot identifies third-party type ? Claims Company |  |
| CP013 | CLAIM OPENED CHECK | bot | chat | Then the chatbot asks: "Has a claim been opened by the passenger?" | Has a claim been opened by the passenger? |
| CP014 | CLAIM OPENED CHECK | system | implied | And the user responds: "No" |  |
| CP015 | COUNTRY OF ORIGIN | bot | chat | Then the chatbot asks: "From which country did the person you are claiming for originate?" | From which country did the person you are claiming for originate? |
| CP016 | COUNTRY OF ORIGIN | customer | chat | And the user provides: "Canada" | Canada |
| CP017 | REJECTION | bot | chat | Then the chatbot responds: "Claims for flight disruption which occurred in Canada must be submitted by the passenger who experienced the dis | Claims for flight disruption which occurred in Canada must be submitted by the passenger who experienced the disruption. Third parties cannot submit claims for  |
| CP018 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything I can help you with?" | Is there anything I can help you with? |
| CP019 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP020 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP021 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the system correctly identifies the claim was NOT opened by the passenger |  |
| CP022 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system skips case number collection and goes directly to country of origin question |  |
| CP023 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the country is "Canada" which is non-EU |  |
| CP024 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the rejection message should be displayed with the correct country |  |
| CP025 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the flow should end with no manual handoff |  |
| CP026 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no case should be created in Claims Dashboard |  |
| CP027 | PAYMENT VALIDATION | payment | manual | Given the third-party submission with no claim opened was rejected for non-EU country |  |
| CP028 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered |  |
| CP029 | PAYMENT VALIDATION | payment | chat | And no case should exist in Claims Dashboard |  |
