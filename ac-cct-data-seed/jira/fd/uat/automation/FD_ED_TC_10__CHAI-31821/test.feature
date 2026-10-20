Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
AMBIGUOUS USER INPUT:
And the user says "My flight was messed up and I'm really frustrated"
INTENT DETECTION � AMBIGUITY DETECTED:
Then the chatbot's intent detection engine analyzes the input:
? Possible Intent 1: Flight Disruption Compensation (FD claim � "flight was messed up" could mean delay/cancellation)
? Possible Intent 2: FAQ / Information Request (customer may want to understand their rights or what happened)
? Possible Intent 3: General Complaint / Feedback (customer may want to lodge a complaint, not seek compensation)
? Confidence Score: BELOW THRESHOLD for any single intent (ambiguous)
? Result: DISAMBIGUATION REQUIRED
DISAMBIGUATION MENU:
Then the chatbot responds:
"I'm sorry to hear about your experience. I'd like to help you with the right thing. Could you tell me more about what you need? Here are some options:
� File a compensation claim � If your flight was delayed, cancelled, or disrupted and you'd like to check if you're eligible for compensation
� Learn about your rights � If you'd like to understand what you're entitled to when a flight is disrupted
� Submit feedback or a complaint � If you'd like to share feedback about your experience
Which of these best describes what you're looking for?"
CUSTOMER SELECTS FD COMPENSATION:
And the user selects "File a compensation claim"
INTENT RESOLVED ? FD COMPENSATION FLOW:
Then the chatbot's intent detection engine updates:
? Resolved Intent: Flight Disruption Compensation
? Confidence: HIGH (customer explicitly selected)
? Routing: FD Compensation Flow
Then the chatbot checks: Is this a third-party submission? ? NO
Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation."
LEGAL DISCLAIMER:
Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need your booking reference, the name associated to the booking and any receipts you'd like to be reimbursed for. If your claim is eligible, you may also need to provide your address, contact information and where you'd like the funds deposited. Would you like to get started?"
NOTE: From this point, the standard FD compensation flow continues (identification ? authentication ? journey selection ? DDS ? result). This TC validates only the intent detection and disambiguation layer.
INTENT DETECTION VALIDATION:
? Input: "My flight was messed up and I'm really frustrated"
? Ambiguity Detected: YES ?
? Disambiguation Menu Presented: YES ?
? Options Offered: FD Compensation, FAQ/Rights, Complaint/Feedback ?
? Customer Selection: "File a compensation claim" ?
? Correct Routing: FD Compensation Flow ?
? No false positive (did not auto-route to wrong intent) ?

Expected Results:
Ambiguous intent detected; System does NOT auto-route; Disambiguation menu presented with 3 options; Customer selection correctly routes to FD compensation flow; Intent transition logged in transcript