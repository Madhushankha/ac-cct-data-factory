# FD_TC_212 · CHAI-31604 — checkpoints

**Goal:** Validates that when a claims company submits on behalf of a passenger, the claim was opened but not found in CS, and the country of origin is an EU-eligible country (France), the system collects required information and sends the case for manual handling.

Methods: seed 4, chat 18, dashboard 7, implied 6, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Validates that when a claims company submits on behalf of a passenger, the claim was opened but not found in CS, and the country of origin i |  |
| CP002 | PREREQUISITES | prerequisite | seed | Third-party caller type: Claims Company | Third-party caller type: Claims Company |
| CP003 | PREREQUISITES | prerequisite | seed | Passenger has opened a claim | Passenger has opened a claim |
| CP004 | PREREQUISITES | prerequisite | seed | Case number not in CS | Case number not in CS |
| CP005 | PREREQUISITES | prerequisite | seed | Country of origin: France | Country of origin: France |
| CP006 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP007 | START | bot | chat | Then the chatbot displays greeting (GLOB-01) |  |
| CP008 | START | customer | chat | Then user selects English |  |
| CP009 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP010 | START | customer | chat | And the user says "I represent a claims company and I need to file a flight disruption claim for a passenger" | I represent a claims company and I need to file a flight disruption claim for a passenger |
| CP011 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP012 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? YES |  |
| CP013 | START | system | implied | Then the chatbot identifies third-party type ? Claims Company |  |
| CP014 | CLAIM OPENED CHECK | bot | chat | Then the chatbot asks: "Has a claim been opened by the passenger?" | Has a claim been opened by the passenger? |
| CP015 | CLAIM OPENED CHECK | system | implied | And the user responds: "Yes" |  |
| CP016 | CASE NUMBER COLLECTION | bot | chat | Then the chatbot responds: "Please provide a case number and the name of one of the passengers on the claim." | Please provide a case number and the name of one of the passengers on the claim. |
| CP017 | CASE NUMBER COLLECTION | customer | chat | And the user provides: Case number "CLM-11223" and passenger name "Sophie Lef�vre" | CLM-11223 Sophie Lef�vre |
| CP018 | CS LOOKUP | system | implied | Then the system checks if the claim exists in Case Services ? NO (not found) |  |
| CP019 | COUNTRY OF ORIGIN | bot | chat | Then the chatbot asks: "From which country did the person you are claiming for originate?" | From which country did the person you are claiming for originate? |
| CP020 | COUNTRY OF ORIGIN | customer | chat | And the user provides: "France" | France |
| CP021 | MANUAL HANDOFF � INFO COLLECTION | customer | chat | Then the chatbot responds: "Thanks, a few questions for me to forward your claim: Please provide the name of claims company, ticket number,  | Thanks, a few questions for me to forward your claim: Please provide the name of claims company, ticket number, booking reference, contact information for the p |
| CP022 | CASE SENT FOR MANUAL HANDLING | system | implied | Then the system creates a case and routes it for manual handling |  |
| CP023 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything I can help you with?" | Is there anything I can help you with? |
| CP024 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP025 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP026 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the system correctly identifies the third-party as a Claims Company |  |
| CP027 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the claim has been opened as YES |  |
| CP028 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CS lookup returns NOT FOUND |  |
| CP029 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the country is "France" which is EU-eligible |  |
| CP030 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the system should prompt for claims company name and ticket number and booking reference and passenger contact info and full passenger  |  |
| CP031 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case should be created and routed for manual handling |  |
| CP032 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claims Dashboard should show case status as "manual review" with third-party type "Claims Company" |  |
| CP033 | PAYMENT VALIDATION | payment | chat | Given the third-party submission was accepted for EU-eligible country and routed to manual handling |  |
| CP034 | PAYMENT VALIDATION | payment | chat | Then no automated payment flow should be triggered |  |
| CP035 | PAYMENT VALIDATION | payment | chat | And the case should be in manual review status |  |
| CP036 | PAYMENT VALIDATION | payment | chat | And any payment should be determined by the reviewing agent |  |
