Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01)
Then user selects English
Then chatbot asks "How can I help you today?"
And the user says "I'm from a claims company, the passenger hasn't filed a claim yet but we need to submit one for a flight disruption"
When the chatbot identifies flight disruption intent
Then the chatbot checks: Is this a third-party submission? ? YES
Then the chatbot identifies third-party type ? Claims Company

CLAIM OPENED CHECK:
Then the chatbot asks: "Has a claim been opened by the passenger?"
And the user responds: "No"

COUNTRY OF ORIGIN (direct):
Then the chatbot asks: "From which country did the person you are claiming for originate?"
And the user provides: "Belgium"

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
    Given the system correctly identifies the claim was NOT opened by the passenger
    And the system skips case number step
    And the country is "Belgium" which is EU-eligible
    Then the manual handoff should be triggered
    And info should be collected including claims company name and ticket number and booking reference and passenger contact info and full passenger names and power of attorney or authorization
    And a case should be created for manual handling
    And the Claims Dashboard should show the case routed for manual review

PAYMENT VALIDATION
    Given the third-party submission with no claim opened was accepted for EU-eligible country
    Then no automated payment flow should be triggered
    And the case should be in manual review status

Expected Results:
