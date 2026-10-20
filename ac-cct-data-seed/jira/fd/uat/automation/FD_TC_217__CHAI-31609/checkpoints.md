# FD_TC_217 · CHAI-31609 — checkpoints

**Goal:** Validates that when a claims company provides a case number that exists in CS, the case is less than 30 days old with no resolution, the system tells them to wait and the user accepts.

Methods: seed 6, chat 21, dashboard 12, implied 8, manual 1, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Validates that when a claims company provides a case number that exists in CS, the case is less than 30 days old with no resolution, the sys |  |
| CP002 | PREREQUISITES | prerequisite | seed | Third-party caller type: Claims Company | Third-party caller type: Claims Company |
| CP003 | PREREQUISITES | prerequisite | seed | Passenger has opened a claim | Passenger has opened a claim |
| CP004 | PREREQUISITES | prerequisite | seed | Case number exists in CS | Case number exists in CS |
| CP005 | PREREQUISITES | prerequisite | seed | Case opened 15 days ago | Case opened 15 days ago |
| CP006 | PREREQUISITES | prerequisite | seed | No resolution on the case | No resolution on the case |
| CP007 | PREREQUISITES | prerequisite | seed | User does NOT dispute | User does NOT dispute |
| CP008 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP009 | START | bot | chat | Then the chatbot displays greeting (GLOB-01) |  |
| CP010 | START | customer | chat | Then user selects English |  |
| CP011 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP012 | START | customer | chat | And the user says "I'm from a claims company following up on a flight disruption claim for a passenger" | I'm from a claims company following up on a flight disruption claim for a passenger |
| CP013 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP014 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? YES |  |
| CP015 | START | system | implied | Then the chatbot identifies third-party type ? Claims Company |  |
| CP016 | CLAIM OPENED CHECK | bot | chat | Then the chatbot asks: "Has a claim been opened by the passenger?" | Has a claim been opened by the passenger? |
| CP017 | CLAIM OPENED CHECK | system | implied | And the user responds: "Yes" |  |
| CP018 | CASE NUMBER COLLECTION | bot | chat | Then the chatbot responds: "Please provide a case number and the name of one of the passengers on the claim." | Please provide a case number and the name of one of the passengers on the claim. |
| CP019 | CASE NUMBER COLLECTION | customer | chat | And the user provides: Case number "CLM-77889" and passenger name "Fran�ois Bergeron" | CLM-77889 Fran�ois Bergeron |
| CP020 | CS LOOKUP | system | implied | Then the system checks if the claim exists in Case Services ? YES (found) |  |
| CP021 | 30-DAY CHECK | system | implied | Then the system checks: Has the case been opened for more than 30 days? ? NO (15 days old) |  |
| CP022 | RESOLUTION CHECK | system | implied | Then the system checks: Was there a resolution on the case? ? NO |  |
| CP023 | WAIT MESSAGE | bot | chat | Then the chatbot responds: "Please wait for the resolution on the case. The passenger should receive an email within 30 days of the case ope | Please wait for the resolution on the case. The passenger should receive an email within 30 days of the case opening. |
| CP024 | USER ACCEPTS | system | implied | And the user responds: "Okay, we'll wait" |  |
| CP025 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything I can help you with?" | Is there anything I can help you with? |
| CP026 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP027 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP028 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the system correctly identifies the third-party as a Claims Company |  |
| CP029 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the claim has been opened as YES |  |
| CP030 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case number "CLM-77889" and passenger name "Fran�ois Bergeron" have been collected |  |
| CP031 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CS lookup returns FOUND |  |
| CP032 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case has been opened for 15 days which is less than 30 days |  |
| CP033 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And there is no resolution on the case |  |
| CP034 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the system should display the wait message "Please wait for the resolution on the case. The passenger should receive an email within 30 |  |
| CP035 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the user accepts the wait message |  |
| CP036 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the flow should end with no manual handoff |  |
| CP037 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no new case should be created in Claims Dashboard |  |
| CP038 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the existing case should remain unchanged in Claims Dashboard |  |
| CP039 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And when searching Claims Dashboard by case number "CLM-77889" only the original case should exist with no new entries |  |
| CP040 | PAYMENT VALIDATION | payment | chat | Given the existing case is still within the 30-day SLA and the user accepted the wait message |  |
| CP041 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered |  |
| CP042 | PAYMENT VALIDATION | payment | chat | And no new compensation record should have been created |  |
| CP043 | PAYMENT VALIDATION | payment | manual | And no new batch file should have been dispatched |  |
| CP044 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP045 | PAYMENT VALIDATION | payment | chat | And no payment method should have been determined |  |
| CP046 | PAYMENT VALIDATION | payment | chat | And no IDV should have been triggered |  |
| CP047 | PAYMENT VALIDATION | payment | chat | And no CyberSource fraud screening should have been triggered |  |
| CP048 | PAYMENT VALIDATION | payment | chat | And the original case's compensation status should remain unchanged |  |
| CP049 | PAYMENT VALIDATION | payment | chat | And no new Claims Dashboard entry should exist for this third-party follow-up |  |
