# FD_TC_213 · CHAI-31605 — checkpoints

**Goal:** Validates that when a claims company is initially rejected for a non-EU country but disputes the rejection, the system escalates to manual handoff by collecting required information.

Methods: seed 5, chat 18, dashboard 6, implied 7, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Validates that when a claims company is initially rejected for a non-EU country but disputes the rejection, the system escalates to manual h |  |
| CP002 | PREREQUISITES | prerequisite | seed | Third-party caller type: Claims Company | Third-party caller type: Claims Company |
| CP003 | PREREQUISITES | prerequisite | seed | Passenger has opened a claim | Passenger has opened a claim |
| CP004 | PREREQUISITES | prerequisite | seed | Case number not in CS | Case number not in CS |
| CP005 | PREREQUISITES | prerequisite | seed | Country of origin: US (non-EU) | Country of origin: US (non-EU) |
| CP006 | PREREQUISITES | prerequisite | seed | User disputes the rejection | User disputes the rejection |
| CP007 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP008 | START | bot | chat | Then the chatbot displays greeting (GLOB-01) |  |
| CP009 | START | customer | chat | Then user selects English |  |
| CP010 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP011 | START | customer | chat | And the user says "I'm from a claims company filing a flight disruption claim on behalf of a passenger" | I'm from a claims company filing a flight disruption claim on behalf of a passenger |
| CP012 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP013 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? YES |  |
| CP014 | START | system | implied | Then the chatbot identifies third-party type ? Claims Company |  |
| CP015 | CLAIM OPENED CHECK | bot | chat | Then the chatbot asks: "Has a claim been opened by the passenger?" | Has a claim been opened by the passenger? |
| CP016 | CLAIM OPENED CHECK | system | implied | And the user responds: "Yes" |  |
| CP017 | CASE NUMBER COLLECTION | bot | chat | Then the chatbot responds: "Please provide a case number and the name of one of the passengers on the claim." | Please provide a case number and the name of one of the passengers on the claim. |
| CP018 | CASE NUMBER COLLECTION | customer | chat | And the user provides: Case number "CLM-44556" and passenger name "Michael Thompson" | CLM-44556 Michael Thompson |
| CP019 | CS LOOKUP | system | implied | Then the system checks if the claim exists in Case Services ? NO (not found) |  |
| CP020 | COUNTRY OF ORIGIN | bot | chat | Then the chatbot asks: "From which country did the person you are claiming for originate?" | From which country did the person you are claiming for originate? |
| CP021 | COUNTRY OF ORIGIN | customer | chat | And the user provides: "United States" | United States |
| CP022 | INITIAL REJECTION | bot | chat | Then the chatbot responds: "Claims for flight disruption which occurred in United States must be submitted by the passenger who experienced  | Claims for flight disruption which occurred in United States must be submitted by the passenger who experienced the disruption. Third parties cannot submit clai |
| CP023 | USER DISPUTES | system | implied | And the user responds: "I disagree, we have authorization from the passenger and need to proceed with this claim" |  |
| CP024 | MANUAL HANDOFF � INFO COLLECTION | customer | chat | Then the chatbot responds: "Thanks, a few questions for me to forward your claim: Please provide the name of claims company, ticket number,  | Thanks, a few questions for me to forward your claim: Please provide the name of claims company, ticket number, booking reference, contact information for the p |
| CP025 | CASE SENT FOR MANUAL HANDLING | system | implied | Then the system creates a case and routes it for manual handling |  |
| CP026 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything I can help you with?" | Is there anything I can help you with? |
| CP027 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP028 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP029 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the system correctly rejects initially for non-EU country "US" |  |
| CP030 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the user disputes the rejection |  |
| CP031 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the system should override the rejection and proceed to manual handoff |  |
| CP032 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the same info collection should occur as EU-eligible path including claims company name and ticket number and booking reference and pass |  |
| CP033 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case should be created and routed for manual handling |  |
| CP034 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claims Dashboard should show the case with dispute override noted |  |
| CP035 | PAYMENT VALIDATION | payment | chat | Given the third-party submission was accepted via dispute override and routed to manual handling |  |
| CP036 | PAYMENT VALIDATION | payment | chat | Then no automated payment flow should be triggered |  |
| CP037 | PAYMENT VALIDATION | payment | chat | And the case should be in manual review status |  |
