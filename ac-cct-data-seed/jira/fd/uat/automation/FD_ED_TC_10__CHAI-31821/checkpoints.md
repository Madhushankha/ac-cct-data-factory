# FD_ED_TC_10 · CHAI-31821 — checkpoints

**Goal:** Customer uses vague language ("my flight was messed up") that could be FD compensation, FAQ about disruption, or general complaint. System must detect ambiguity, present disambiguation options, and route correctly based on customer selection. Tests the Intent Detection ? Disambiguation path from Miro.

Methods: seed 1, chat 11, implied 4, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Customer uses vague language ("my flight was messed up") that could be FD compensation, FAQ about disruption, or general complaint. System m |  |
| CP002 | PREREQUISITES | prerequisite | seed | None � tests intent detection layer only before identification | None � tests intent detection layer only before identification |
| CP003 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP004 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP005 | START | customer | chat | Then user selects English |  |
| CP006 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP007 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP008 | AMBIGUOUS USER INPUT | customer | chat | And the user says "My flight was messed up and I'm really frustrated" | My flight was messed up and I'm really frustrated |
| CP009 | INTENT DETECTION � AMBIGUITY DETECTED | system | implied | Then the chatbot's intent detection engine analyzes the input: | ? Possible Intent 1: Flight Disruption Compensation (FD claim � "flight was messed up" could mean delay/cancellation) ? Possible Intent 2: FAQ / Information Req |
| CP010 | DISAMBIGUATION MENU | bot | chat | Then the chatbot responds: | I'm sorry to hear about your experience. I'd like to help you with the right thing. Could you tell me more about what you need? Here are some options: � File a  |
| CP011 | CUSTOMER SELECTS FD COMPENSATION | customer | chat | And the user selects "File a compensation claim" | File a compensation claim |
| CP012 | INTENT RESOLVED ? FD COMPENSATION FLOW | system | implied | Then the chatbot's intent detection engine updates: | ? Resolved Intent: Flight Disruption Compensation ? Confidence: HIGH (customer explicitly selected) ? Routing: FD Compensation Flow |
| CP013 | INTENT RESOLVED ? FD COMPENSATION FLOW | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP014 | INTENT RESOLVED ? FD COMPENSATION FLOW | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP015 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP016 | INTENT DETECTION VALIDATION | system | implied | ? Input: "My flight was messed up and I'm really frustrated" | ? Ambiguity Detected: YES ? ? Disambiguation Menu Presented: YES ? ? Options Offered: FD Compensation, FAQ/Rights, Complaint/Feedback ? ? Customer Selection: "F |
| CP017 | EXPECTED RESULTS | verdict | chat | Ambiguous intent detected; System does NOT auto-route; Disambiguation menu presented with 3 options; Customer selection correctly routes to  | Ambiguous intent detected; System does NOT auto-route; Disambiguation menu presented with 3 options; Customer selection correctly routes to FD compensation flow |
