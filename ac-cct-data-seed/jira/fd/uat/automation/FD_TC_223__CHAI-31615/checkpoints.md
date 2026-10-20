# FD_TC_223 · CHAI-31615 — checkpoints

**Goal:** Validates that when a family member or friend cannot pass OTP authentication, the system requires them to upload proof of authority (POA/authorization document) and routes the case for manual handling.

Methods: seed 2, chat 17, dashboard 9, implied 9, manual 2, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Validates that when a family member or friend cannot pass OTP authentication, the system requires them to upload proof of authority (POA/aut |  |
| CP002 | PREREQUISITES | prerequisite | seed | Third-party caller type: Parent/Guardian/Family/Friend | Third-party caller type: Parent/Guardian/Family/Friend |
| CP003 | PREREQUISITES | prerequisite | seed | OTP authentication fails (wrong code or passenger unreachable) | OTP authentication fails (wrong code or passenger unreachable) |
| CP004 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP005 | START | bot | chat | Then the chatbot displays greeting (GLOB-01) |  |
| CP006 | START | customer | chat | Then user selects English |  |
| CP007 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP008 | START | customer | chat | And the user says "I'm filing a flight disruption claim for my elderly mother who can't use the computer" | I'm filing a flight disruption claim for my elderly mother who can't use the computer |
| CP009 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP010 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? YES |  |
| CP011 | START | system | implied | Then the chatbot identifies third-party type ? Parent/Guardian/Family/Friend |  |
| CP012 | OTP AUTHENTICATION | system | implied | Then the chatbot initiates OTP verification |  |
| CP013 | OTP AUTHENTICATION | system | implied | And the user responds: "She doesn't have access to her phone right now, I can't get the code" |  |
| CP014 | OTP FAILED | system | implied | Then the system marks OTP ? FAILED / NOT COMPLETED |  |
| CP015 | DOCUMENT UPLOAD REQUIRED | bot | chat | Then the chatbot responds: "Since we're unable to verify through OTP, you'll need to upload a document proving you have the authority to act | Since we're unable to verify through OTP, you'll need to upload a document proving you have the authority to act on behalf of the passenger (e.g., Power of Atto |
| CP016 | DOCUMENT UPLOAD REQUIRED | system | implied | And the chatbot collects: ticket number, booking reference, contact information for the passenger, full passenger names, and requests docume |  |
| CP017 | DOCUMENT UPLOAD REQUIRED | system | implied | And the user uploads the authorization document and provides required information |  |
| CP018 | CASE SENT FOR MANUAL HANDLING | system | implied | Then the system creates a case and routes it for manual handling (intake approval required) |  |
| CP019 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything I can help you with?" | Is there anything I can help you with? |
| CP020 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP021 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP022 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the system correctly identifies the third-party as "Parent/Guardian/Family/Friend" |  |
| CP023 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And OTP authentication has been initiated |  |
| CP024 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the user cannot provide the correct OTP code as the passenger is unreachable |  |
| CP025 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system marks OTP as FAILED or NOT COMPLETED |  |
| CP026 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the system should fall back to the document upload path |  |
| CP027 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should collect ticket number and booking reference and contact information for the passenger and full passenger names and req |  |
| CP028 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the user uploads the authorization document and provides required information |  |
| CP029 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case should be created and routed for manual handling with intake approval flag |  |
| CP030 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claims Dashboard should show the case with third-party type "Family/Friend � OTP Failed" and status "Manual Review" and intake appro |  |
| CP031 | PAYMENT VALIDATION | payment | chat | Given the Family/Friend OTP failed and the case was routed to manual handling with POA upload |  |
| CP032 | PAYMENT VALIDATION | payment | chat | Then no automated payment flow should be triggered |  |
| CP033 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked during the chatbot flow |  |
| CP034 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created automatically |  |
| CP035 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP036 | PAYMENT VALIDATION | payment | chat | And no IDV should have been triggered via the automated flow |  |
| CP037 | PAYMENT VALIDATION | payment | chat | And no CyberSource fraud screening should have been triggered via the automated flow |  |
| CP038 | PAYMENT VALIDATION | payment | chat | And the case should be in manual review status with intake approval required |  |
| CP039 | PAYMENT VALIDATION | payment | manual | And if the agent later approves intake and determines eligible manual compensation should be created and payment dispatched per type with ca |  |
| CP040 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show case status as "Manual Review � Intake Approval Required" with no payout section until manually resolve |  |
