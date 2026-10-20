Given the user opens the agentic chatbot Then the chatbot displays greeting (GLOB-01)
Then user selects English Then chatbot asks "How can I help you today?"
And the user says "I'm calling from a claims company on behalf of a passenger regarding a flight disruption claim"
When the chatbot identifies flight disruption intent
Then the chatbot checks: Is this a third-party submission? ? YES
Then the chatbot identifies third-party type ? Claims Company

CLAIM OPENED CHECK:
Then the chatbot asks: "Has a claim been opened by the passenger?"
And the user responds: "Yes"

CASE NUMBER COLLECTION:
Then the chatbot responds: "Please provide a case number and the name of one of the passengers on the claim."
And the user provides: Case number "CLM-98765" and passenger name "Jean-Pierre Martin"

CS LOOKUP: Then the system checks if the claim exists in Case Services ? NO (not found)

COUNTRY OF ORIGIN: Then the chatbot asks: "From which country did the person you are claiming for originate?"
And the user provides: "Canada"

REJECTION:
Then the chatbot responds: "Claims for flight disruption which occurred in Canada must be submitted by the passenger who experienced the disruption. Third parties cannot submit claims for disruption that occur in Canada. Please advise the passenger to open a claim themselves."

END FLOW (GLOB-11):
Then the chatbot offers: "Is there anything I can help you with?"
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given the system correctly identifies the third-party as a Claims Company
    And the claim has been opened as YES
    And the case number and passenger name have been collected
    And the CS lookup returns NOT FOUND
    And the country is "Canada" which is non-EU
    Then the system should display the rejection message with the correct country name inserted
    And the flow should end with no manual handoff
    And no case should be created in Claims Dashboard
    And when searching Claims Dashboard no entry should exist for this third-party submission

PAYMENT VALIDATION
    Given the third-party submission was rejected for non-EU country
    Then no payment flow should be triggered
    And no case should exist in Claims Dashboard
    And no compensation record should have been created
