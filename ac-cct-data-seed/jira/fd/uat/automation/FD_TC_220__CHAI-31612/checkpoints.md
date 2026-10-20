# FD_TC_220 · CHAI-31612 — checkpoints

**Goal:** Validates system behavior when a Travel Agency disputes the rejection. The system should maintain the rejection or escalate to manual handling depending on implementation.

Methods: seed 2, chat 16, dashboard 7, implied 5, manual 2, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Validates system behavior when a Travel Agency disputes the rejection. The system should maintain the rejection or escalate to manual handli |  |
| CP002 | PREREQUISITES | prerequisite | seed | Third-party caller type: Travel Agency | Third-party caller type: Travel Agency |
| CP003 | PREREQUISITES | prerequisite | seed | User disputes the initial rejection | User disputes the initial rejection |
| CP004 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP005 | START | bot | chat | Then the chatbot displays greeting (GLOB-01) |  |
| CP006 | START | customer | chat | Then user selects English |  |
| CP007 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP008 | START | customer | chat | And the user says "I'm calling from a travel agency, my elderly client cannot file the claim themselves and I need to do it for them" | I'm calling from a travel agency, my elderly client cannot file the claim themselves and I need to do it for them |
| CP009 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP010 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? YES |  |
| CP011 | START | system | implied | Then the chatbot identifies third-party type ? Travel Agency |  |
| CP012 | INITIAL REJECTION | bot | chat | Then the chatbot responds advising the customer must submit the claim themselves. |  |
| CP013 | USER DISPUTES | system | implied | And the user responds: "My client is elderly and unable to use the system, I have their authorization to act on their behalf" |  |
| CP014 | SYSTEM RESPONSE | system | implied | Then the chatbot either: (a) Maintains rejection and reiterates that the customer must submit the claim, OR (b) Escalates to manual handoff  |  |
| CP015 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything I can help you with?" | Is there anything I can help you with? |
| CP016 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP017 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP018 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the system correctly identifies the third-party type as "Travel Agency" |  |
| CP019 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the initial rejection is displayed advising the customer must submit the claim themselves |  |
| CP020 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the user disputes the rejection citing the passenger is elderly and unable to use the system |  |
| CP021 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the system should either maintain the hard rejection and reiterate that the customer must submit the claim themselves OR escalate to ma |  |
| CP022 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the actual system behavior should be documented for UAT validation |  |
| CP023 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And if the system maintains rejection then no case should be created and no manual handoff should occur |  |
| CP024 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And if the system escalates then a case should be created and routed for manual handling |  |
| CP025 | PAYMENT VALIDATION | payment | manual | Given the Travel Agency submission was either maintained as rejected or escalated to manual handoff after dispute |  |
| CP026 | PAYMENT VALIDATION | payment | chat | Then no automated payment flow should be triggered regardless of the dispute outcome |  |
| CP027 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked during the chatbot flow |  |
| CP028 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created automatically |  |
| CP029 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP030 | PAYMENT VALIDATION | payment | chat | And no IDV should have been triggered |  |
| CP031 | PAYMENT VALIDATION | payment | chat | And no CyberSource fraud screening should have been triggered |  |
| CP032 | PAYMENT VALIDATION | payment | chat | And if the system maintained rejection then no case should exist and no payment is possible |  |
| CP033 | PAYMENT VALIDATION | payment | chat | And if the system escalated to manual handoff then any payment should be determined by the reviewing agent and the Claims Dashboard should s |  |
