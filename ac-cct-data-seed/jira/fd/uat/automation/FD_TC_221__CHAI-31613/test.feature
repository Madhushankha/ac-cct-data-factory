Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01)
Then user selects English
Then chatbot asks "How can I help you today?"
And the user says "I'm an executive assistant filing a flight disruption claim on behalf of my executive"
When the chatbot identifies flight disruption intent
Then the chatbot checks: Is this a third-party submission? ? YES
Then the chatbot identifies third-party type ? Executive Assistant / Travel Agency

REJECTION:
Then the chatbot responds advising that the customer must submit the claim themselves.

END FLOW (GLOB-11):
Then the chatbot offers: "Is there anything I can help you with?"
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given the system correctly identifies the third-party type as "Executive Assistant" which is the same category as Travel Agency
    Then the system should immediately reject the submission advising the customer must file themselves
    And no case should be created in Claims Dashboard
    And no manual handoff should occur
    And the flow should end
    And when searching Claims Dashboard no entry should exist for this Executive Assistant submission

PAYMENT VALIDATION
    Given the Executive Assistant submission was hard rejected per policy as same category as Travel Agency
    Then no payment flow should be triggered
    And no case should exist in Claims Dashboard
    And no compensation record should have been created
    And no batch file should have been dispatched
    And no country of residence should have been asked
    And no IDV should have been triggered
    And no CyberSource fraud screening should have been triggered

Expected Results:
