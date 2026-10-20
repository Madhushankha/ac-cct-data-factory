Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01)
Then user selects English
Then chatbot asks "How can I help you today?"
And the user says "I'm a claims company and I want to submit a flight disruption claim for a passenger"
When the chatbot identifies flight disruption intent
Then the chatbot checks: Is this a third-party submission? ? YES
Then the chatbot identifies third-party type ? Claims Company

CLAIM OPENED CHECK:
Then the chatbot asks: "Has a claim been opened by the passenger?"
And the user responds: "No"

COUNTRY OF ORIGIN (direct, no case number step):
Then the chatbot asks: "From which country did the person you are claiming for originate?"
And the user provides: "Canada"

REJECTION:
Then the chatbot responds: "Claims for flight disruption which occurred in Canada must be submitted by the passenger who experienced the disruption. Third parties cannot submit claims for disruption that occur in Canada. Please advise the passenger to open a claim themselves."

END FLOW (GLOB-11):
Then the chatbot offers: "Is there anything I can help you with?"
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given the system correctly identifies the claim was NOT opened by the passenger
    And the system skips case number collection and goes directly to country of origin question
    And the country is "Canada" which is non-EU
    Then the rejection message should be displayed with the correct country
    And the flow should end with no manual handoff
    And no case should be created in Claims Dashboard

PAYMENT VALIDATION
    Given the third-party submission with no claim opened was rejected for non-EU country
    Then no payment flow should be triggered
    And no case should exist in Claims Dashboard
