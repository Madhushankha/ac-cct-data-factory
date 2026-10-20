# FD_TC_211 · CHAI-31603 — checkpoints

**Goal:** Validates that when a claims company submits on behalf of a passenger, the claim was opened by the passenger, the case number is not found in CS, and the country of origin is a non-EU country (e.g., Canada), the system rejects the third-party submission and advises the passenger to file themselves.

Methods: seed 4, chat 14, dashboard 9, implied 4, manual 1, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Validates that when a claims company submits on behalf of a passenger, the claim was opened by the passenger, the case number is not found i |  |
| CP002 | PREREQUISITES | prerequisite | seed | Third-party caller type: Claims Company | Third-party caller type: Claims Company |
| CP003 | PREREQUISITES | prerequisite | seed | Passenger has opened a claim | Passenger has opened a claim |
| CP004 | PREREQUISITES | prerequisite | seed | Case number provided does not exist in Case Services | Case number provided does not exist in Case Services |
| CP005 | PREREQUISITES | prerequisite | seed | Country of origin: Canada | Country of origin: Canada |
| CP006 | START | customer | chat | Given the user opens the agentic chatbot Then the chatbot displays greeting (GLOB-01) |  |
| CP007 | START | customer | chat | Then user selects English Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP008 | START | customer | chat | And the user says "I'm calling from a claims company on behalf of a passenger regarding a flight disruption claim" | I'm calling from a claims company on behalf of a passenger regarding a flight disruption claim |
| CP009 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP010 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? YES |  |
| CP011 | START | system | implied | Then the chatbot identifies third-party type ? Claims Company |  |
| CP012 | CLAIM OPENED CHECK | bot | chat | Then the chatbot asks: "Has a claim been opened by the passenger?" | Has a claim been opened by the passenger? |
| CP013 | CLAIM OPENED CHECK | system | implied | And the user responds: "Yes" |  |
| CP014 | CASE NUMBER COLLECTION | bot | chat | Then the chatbot responds: "Please provide a case number and the name of one of the passengers on the claim." | Please provide a case number and the name of one of the passengers on the claim. |
| CP015 | CASE NUMBER COLLECTION | customer | chat | And the user provides: Case number "CLM-98765" and passenger name "Jean-Pierre Martin" | CLM-98765 Jean-Pierre Martin |
| CP016 | CASE NUMBER COLLECTION | customer | chat | And the user provides: "Canada" | Canada |
| CP017 | REJECTION | bot | chat | Then the chatbot responds: "Claims for flight disruption which occurred in Canada must be submitted by the passenger who experienced the dis | Claims for flight disruption which occurred in Canada must be submitted by the passenger who experienced the disruption. Third parties cannot submit claims for  |
| CP018 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything I can help you with?" | Is there anything I can help you with? |
| CP019 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP020 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP021 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the system correctly identifies the third-party as a Claims Company |  |
| CP022 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the claim has been opened as YES |  |
| CP023 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case number and passenger name have been collected |  |
| CP024 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CS lookup returns NOT FOUND |  |
| CP025 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the country is "Canada" which is non-EU |  |
| CP026 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the system should display the rejection message with the correct country name inserted |  |
| CP027 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the flow should end with no manual handoff |  |
| CP028 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no case should be created in Claims Dashboard |  |
| CP029 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And when searching Claims Dashboard no entry should exist for this third-party submission |  |
| CP030 | PAYMENT VALIDATION | payment | manual | Given the third-party submission was rejected for non-EU country |  |
| CP031 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered |  |
| CP032 | PAYMENT VALIDATION | payment | chat | And no case should exist in Claims Dashboard |  |
| CP033 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created |  |
