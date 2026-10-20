# FD_TC_225 · CHAI-31617 — checkpoints

**Goal:** Validates that when an individual claims to have authority but cannot or refuses to upload proof of authorization, the system denies the claim.

Methods: seed 2, chat 17, dashboard 8, implied 4, manual 1, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Validates that when an individual claims to have authority but cannot or refuses to upload proof of authorization, the system denies the cla |  |
| CP002 | PREREQUISITES | prerequisite | seed | Third-party caller type: Legal/Guardian/Tutor/Insurer/FI | Third-party caller type: Legal/Guardian/Tutor/Insurer/FI |
| CP003 | PREREQUISITES | prerequisite | seed | User cannot provide documentation | User cannot provide documentation |
| CP004 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP005 | START | bot | chat | Then the chatbot displays greeting (GLOB-01) |  |
| CP006 | START | customer | chat | Then user selects English |  |
| CP007 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP008 | START | customer | chat | And the user says "I'm an insurer and I need to file a disruption claim for one of our policyholders" | I'm an insurer and I need to file a disruption claim for one of our policyholders |
| CP009 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP010 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? YES |  |
| CP011 | START | system | implied | Then the chatbot identifies third-party type ? Insurer/FI |  |
| CP012 | DOCUMENT UPLOAD REQUIRED | bot | chat | Then the chatbot responds: "To proceed with your claim, you'll need to upload a document proving you have the authority to act on behalf of  | To proceed with your claim, you'll need to upload a document proving you have the authority to act on behalf of the passenger. |
| CP013 | USER CANNOT PROVIDE | system | implied | And the user responds: "I don't have a power of attorney document right now" |  |
| CP014 | DENIAL | bot | chat | Then the chatbot responds: "We're unable to process a claim on behalf of a passenger without proper documentation proving your authority to  | We're unable to process a claim on behalf of a passenger without proper documentation proving your authority to act on their behalf. Please obtain the necessary |
| CP015 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything I can help you with?" | Is there anything I can help you with? |
| CP016 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP017 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP018 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the system correctly identifies the third-party as "Insurer/FI" |  |
| CP019 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the document upload has been requested |  |
| CP020 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the user cannot provide a power of attorney document |  |
| CP021 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the system should deny the claim with a clear message explaining documentation is required |  |
| CP022 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no case should be created in Claims Dashboard |  |
| CP023 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no manual handoff should occur |  |
| CP024 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the flow should end |  |
| CP025 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And when searching Claims Dashboard no entry should exist for this submission |  |
| CP026 | PAYMENT VALIDATION | payment | chat | Given the Individual with POA submission was denied due to no documentation provided |  |
| CP027 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered |  |
| CP028 | PAYMENT VALIDATION | payment | chat | And no case should exist in Claims Dashboard |  |
| CP029 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created |  |
| CP030 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP031 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP032 | PAYMENT VALIDATION | payment | chat | And no IDV should have been triggered |  |
| CP033 | PAYMENT VALIDATION | payment | chat | And no CyberSource fraud screening should have been triggered |  |
