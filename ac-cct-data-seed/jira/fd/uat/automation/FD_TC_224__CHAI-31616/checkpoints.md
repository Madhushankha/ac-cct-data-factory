# FD_TC_224 · CHAI-31616 — checkpoints

**Goal:** Validates that when an individual with legal authority (lawyer, tutor, insurer, financial institution) submits a claim, the system requires POA/authorization upload and routes for manual handling.

Methods: seed 3, chat 18, dashboard 7, implied 6, manual 2, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Validates that when an individual with legal authority (lawyer, tutor, insurer, financial institution) submits a claim, the system requires  |  |
| CP002 | PREREQUISITES | prerequisite | seed | Third-party caller type: Legal representative / Tutor / Insurer / FI | Third-party caller type: Legal representative / Tutor / Insurer / FI |
| CP003 | PREREQUISITES | prerequisite | seed | Not a claims company | Not a claims company |
| CP004 | PREREQUISITES | prerequisite | seed | Not family/friend | Not family/friend |
| CP005 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP006 | START | bot | chat | Then the chatbot displays greeting (GLOB-01) |  |
| CP007 | START | customer | chat | Then user selects English |  |
| CP008 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP009 | START | customer | chat | And the user says "I'm the legal guardian of a minor and I need to submit a flight disruption claim on their behalf" | I'm the legal guardian of a minor and I need to submit a flight disruption claim on their behalf |
| CP010 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP011 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? YES |  |
| CP012 | START | system | implied | Then the chatbot identifies third-party type ? Legal/Guardian/Tutor/Insurer/FI |  |
| CP013 | DOCUMENT UPLOAD REQUIRED | bot | chat | Then the chatbot responds: "To proceed with your claim, you'll need to upload a document proving you have the authority to act on behalf of  | To proceed with your claim, you'll need to upload a document proving you have the authority to act on behalf of the passenger (e.g., Power of Attorney, guardian |
| CP014 | DOCUMENT UPLOAD REQUIRED | system | implied | And the chatbot collects: ticket number, booking reference, contact information for the passenger, full passenger names, and requests docume |  |
| CP015 | DOCUMENT UPLOAD REQUIRED | system | implied | And the user uploads the guardianship document and provides required information |  |
| CP016 | CASE SENT FOR MANUAL HANDLING | system | implied | Then the system creates a case and routes it for manual handling |  |
| CP017 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything I can help you with?" | Is there anything I can help you with? |
| CP018 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP019 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP020 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the system correctly identifies the third-party as "Legal/Guardian/Tutor/Insurer/FI" |  |
| CP021 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no OTP path should be offered as this is not Family/Friend |  |
| CP022 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the system should go directly to the document upload requirement |  |
| CP023 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should collect ticket number and booking reference and contact information for the passenger and full passenger names and req |  |
| CP024 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the user uploads the guardianship document and provides required information |  |
| CP025 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case should be created and routed for manual handling with intake approval flag |  |
| CP026 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claims Dashboard should show the case with third-party type "Legal/Guardian/Tutor/Insurer/FI" and status "Manual Review" and intake  |  |
| CP027 | PAYMENT VALIDATION | payment | chat | Given the Individual with POA submission was routed to manual handling |  |
| CP028 | PAYMENT VALIDATION | payment | chat | Then no automated payment flow should be triggered |  |
| CP029 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked during the chatbot flow |  |
| CP030 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created automatically |  |
| CP031 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP032 | PAYMENT VALIDATION | payment | chat | And no IDV should have been triggered via the automated flow |  |
| CP033 | PAYMENT VALIDATION | payment | chat | And no CyberSource fraud screening should have been triggered via the automated flow |  |
| CP034 | PAYMENT VALIDATION | payment | chat | And the case should be in manual review status with intake approval required |  |
| CP035 | PAYMENT VALIDATION | payment | manual | And if the agent later approves intake and determines eligible manual compensation should be created and payment dispatched per type with ca |  |
| CP036 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show case status as "Manual Review � Intake Approval Required" with no payout section until manually resolve |  |
| CP037 | PAYMENT VALIDATION | payment | chat | And no automated path exists for this third-party category per policy |  |
