# FD_TC_221 · CHAI-31613 — checkpoints

**Goal:** Validates that when an Executive Assistant attempts to submit a flight disruption claim on behalf of a passenger, the system rejects the submission similarly to a Travel Agency.

Methods: seed 1, chat 15, dashboard 6, implied 3, manual 2, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Validates that when an Executive Assistant attempts to submit a flight disruption claim on behalf of a passenger, the system rejects the sub |  |
| CP002 | PREREQUISITES | prerequisite | seed | Third-party caller type: Executive Assistant | Third-party caller type: Executive Assistant |
| CP003 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP004 | START | bot | chat | Then the chatbot displays greeting (GLOB-01) |  |
| CP005 | START | customer | chat | Then user selects English |  |
| CP006 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP007 | START | customer | chat | And the user says "I'm an executive assistant filing a flight disruption claim on behalf of my executive" | I'm an executive assistant filing a flight disruption claim on behalf of my executive |
| CP008 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP009 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? YES |  |
| CP010 | START | system | implied | Then the chatbot identifies third-party type ? Executive Assistant / Travel Agency |  |
| CP011 | REJECTION | bot | chat | Then the chatbot responds advising that the customer must submit the claim themselves. |  |
| CP012 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything I can help you with?" | Is there anything I can help you with? |
| CP013 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP014 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP015 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the system correctly identifies the third-party type as "Executive Assistant" which is the same category as Travel Agency |  |
| CP016 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the system should immediately reject the submission advising the customer must file themselves |  |
| CP017 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no case should be created in Claims Dashboard |  |
| CP018 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no manual handoff should occur |  |
| CP019 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the flow should end |  |
| CP020 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And when searching Claims Dashboard no entry should exist for this Executive Assistant submission |  |
| CP021 | PAYMENT VALIDATION | payment | manual | Given the Executive Assistant submission was hard rejected per policy as same category as Travel Agency |  |
| CP022 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered |  |
| CP023 | PAYMENT VALIDATION | payment | chat | And no case should exist in Claims Dashboard |  |
| CP024 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created |  |
| CP025 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP026 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP027 | PAYMENT VALIDATION | payment | chat | And no IDV should have been triggered |  |
| CP028 | PAYMENT VALIDATION | payment | chat | And no CyberSource fraud screening should have been triggered |  |
