# FD_TC_218 · CHAI-31610 — checkpoints

**Goal:** Validates that when a claims company is told to wait but disputes, the system escalates to manual handoff.

Methods: seed 6, chat 22, dashboard 12, implied 9, manual 3, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Validates that when a claims company is told to wait but disputes, the system escalates to manual handoff. |  |
| CP002 | PREREQUISITES | prerequisite | seed | Third-party caller type: Claims Company | Third-party caller type: Claims Company |
| CP003 | PREREQUISITES | prerequisite | seed | Passenger has opened a claim | Passenger has opened a claim |
| CP004 | PREREQUISITES | prerequisite | seed | Case number exists in CS | Case number exists in CS |
| CP005 | PREREQUISITES | prerequisite | seed | Case opened 20 days ago | Case opened 20 days ago |
| CP006 | PREREQUISITES | prerequisite | seed | No resolution | No resolution |
| CP007 | PREREQUISITES | prerequisite | seed | User disputes the wait message | User disputes the wait message |
| CP008 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP009 | START | bot | chat | Then the chatbot displays greeting (GLOB-01) |  |
| CP010 | START | customer | chat | Then user selects English |  |
| CP011 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP012 | START | customer | chat | And the user says "I'm from a claims company, we need an update on a flight disruption claim" | I'm from a claims company, we need an update on a flight disruption claim |
| CP013 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP014 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? YES |  |
| CP015 | START | system | implied | Then the chatbot identifies third-party type ? Claims Company |  |
| CP016 | CLAIM OPENED CHECK | bot | chat | Then the chatbot asks: "Has a claim been opened by the passenger?" | Has a claim been opened by the passenger? |
| CP017 | CLAIM OPENED CHECK | system | implied | And the user responds: "Yes" |  |
| CP018 | CASE NUMBER COLLECTION | bot | chat | Then the chatbot responds: "Please provide a case number and the name of one of the passengers on the claim." | Please provide a case number and the name of one of the passengers on the claim. |
| CP019 | CASE NUMBER COLLECTION | customer | chat | And the user provides: Case number "CLM-99001" and passenger name "�milie Gagnon" | CLM-99001 �milie Gagnon |
| CP020 | CS LOOKUP | system | implied | Then the system checks if the claim exists in Case Services ? YES (found) |  |
| CP021 | 30-DAY CHECK | system | implied | Then the system checks: Has the case been opened for more than 30 days? ? NO (20 days old) |  |
| CP022 | RESOLUTION CHECK | system | implied | Then the system checks: Was there a resolution on the case? ? NO |  |
| CP023 | WAIT MESSAGE | bot | chat | Then the chatbot responds: "Please wait for the resolution on the case. The passenger should receive an email within 30 days of the case ope | Please wait for the resolution on the case. The passenger should receive an email within 30 days of the case opening. |
| CP024 | USER DISPUTES | system | implied | And the user responds: "This is unacceptable, we need this escalated immediately" |  |
| CP025 | MANUAL HANDOFF � INFO COLLECTION | bot | chat | Then the chatbot responds: "Thanks, a few questions for me to forward your claim: Please provide the name of claims company, ticket number,  | Thanks, a few questions for me to forward your claim: Please provide the name of claims company, ticket number, booking reference, contact information for the p |
| CP026 | MANUAL HANDOFF � INFO COLLECTION | customer | chat | And the user provides all required information |  |
| CP027 | CASE SENT FOR MANUAL HANDLING | system | implied | Then the system creates a case and routes it for manual handling |  |
| CP028 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything I can help you with?" | Is there anything I can help you with? |
| CP029 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP030 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP031 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the system correctly identifies the third-party as a Claims Company |  |
| CP032 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the claim has been opened as YES |  |
| CP033 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case number "CLM-99001" and passenger name "�milie Gagnon" have been collected |  |
| CP034 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CS lookup returns FOUND |  |
| CP035 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case has been opened for 20 days which is less than 30 days |  |
| CP036 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And there is no resolution on the case |  |
| CP037 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the system should display the wait message "Please wait for the resolution on the case. The passenger should receive an email within 30 |  |
| CP038 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the user disputes the wait message |  |
| CP039 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the system should override and proceed to manual handoff |  |
| CP040 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should collect claims company name and ticket number and booking reference and contact information for the passenger and full |  |
| CP041 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the user provides all required information |  |
| CP042 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case should be created or updated and routed for manual handling |  |
| CP043 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Claims Dashboard should show the case routed for manual review with the dispute override noted in the audit log |  |
| CP044 | PAYMENT VALIDATION | payment | chat | Given the existing case was within the 30-day SLA but the user disputed and the case was escalated to manual handoff |  |
| CP045 | PAYMENT VALIDATION | payment | chat | Then no automated payment flow should be triggered |  |
| CP046 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked during the chatbot flow |  |
| CP047 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created automatically |  |
| CP048 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP049 | PAYMENT VALIDATION | payment | chat | And no IDV should have been triggered |  |
| CP050 | PAYMENT VALIDATION | payment | chat | And no CyberSource fraud screening should have been triggered |  |
| CP051 | PAYMENT VALIDATION | payment | chat | And the case should be in manual review status |  |
| CP052 | PAYMENT VALIDATION | payment | manual | And if the agent later determines eligible manual compensation should be created and payment dispatched per type with cash to Unifier and e- |  |
| CP053 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show case status as "Manual Review" with no payout section until manually resolved |  |
