Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01)
Then user selects English
Then chatbot asks "How can I help you today?"
And the user says "Claims company here, I need to file a disruption claim for a passenger"
When the chatbot identifies flight disruption intent
Then the chatbot checks: Is this a third-party submission? ? YES
Then the chatbot identifies third-party type ? Claims Company

CLAIM OPENED CHECK:
Then the chatbot asks: "Has a claim been opened by the passenger?"
And the user responds: "No"

COUNTRY OF ORIGIN:
Then the chatbot asks: "From which country did the person you are claiming for originate?"
And the user provides: "United States"

INITIAL REJECTION:
Then the chatbot responds: "Claims for flight disruption which occurred in United States must be submitted by the passenger who experienced the disruption. Third parties cannot submit claims for disruption that occur in United States. Please advise the passenger to open a claim themselves."

USER DISPUTES:
And the user responds: "We have legal authorization and insist on proceeding"

MANUAL HANDOFF � INFO COLLECTION:
Then the chatbot responds: "Thanks, a few questions for me to forward your claim: Please provide the name of claims company, ticket number, booking reference, contact information for the passenger, full passenger names for your claim. You'll also need to upload the power of attorney or notice of authorization to have your claim actioned."
And the user provides all required information

CASE SENT FOR MANUAL HANDLING:
Then the system creates a case and routes it for manual handling

END FLOW (GLOB-11):
Then the chatbot offers: "Is there anything I can help you with?"
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given the system rejects for non-EU country
    And the user disputes the rejection
    Then the system should override and proceed to manual handoff with full info collection
    And a case should be created for manual handling
    And the Claims Dashboard should show the case with dispute override noted
    And this mirrors TC187 but on the "no claim opened" branch

PAYMENT VALIDATION
    Given the third-party submission with no claim opened was accepted via dispute override
    Then no automated payment flow should be triggered
    And the case should be in manual review status

Expected Results:
