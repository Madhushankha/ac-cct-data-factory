Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01)
Then user selects English
Then chatbot asks "How can I help you today?"
And the user says "I'm from a claims company filing a flight disruption claim on behalf of a passenger"
When the chatbot identifies flight disruption intent
Then the chatbot checks: Is this a third-party submission? ? YES
Then the chatbot identifies third-party type ? Claims Company

CLAIM OPENED CHECK:
Then the chatbot asks: "Has a claim been opened by the passenger?"
And the user responds: "Yes"

CASE NUMBER COLLECTION:
Then the chatbot responds: "Please provide a case number and the name of one of the passengers on the claim."
And the user provides: Case number "CLM-44556" and passenger name "Michael Thompson"

CS LOOKUP:
Then the system checks if the claim exists in Case Services ? NO (not found)

COUNTRY OF ORIGIN:
Then the chatbot asks: "From which country did the person you are claiming for originate?"
And the user provides: "United States"

INITIAL REJECTION:
Then the chatbot responds: "Claims for flight disruption which occurred in United States must be submitted by the passenger who experienced the disruption. Third parties cannot submit claims for disruption that occur in United States. Please advise the passenger to open a claim themselves."

USER DISPUTES:
And the user responds: "I disagree, we have authorization from the passenger and need to proceed with this claim"

MANUAL HANDOFF � INFO COLLECTION:
Then the chatbot responds: "Thanks, a few questions for me to forward your claim: Please provide the name of claims company, ticket number, booking reference, contact information for the passenger, full passenger names for your claim. You'll also need to upload the power of attorney or notice of authorization to have your claim actioned." And the user provides all required information

CASE SENT FOR MANUAL HANDLING:
Then the system creates a case and routes it for manual handling

END FLOW (GLOB-11):
Then the chatbot offers: "Is there anything I can help you with?"
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given the system correctly rejects initially for non-EU country "US"
    And the user disputes the rejection
    Then the system should override the rejection and proceed to manual handoff
    And the same info collection should occur as EU-eligible path including claims company name and ticket number and booking reference and passenger contact info and full passenger names and power of attorney or authorization
    And a case should be created and routed for manual handling
    And the Claims Dashboard should show the case with dispute override noted

PAYMENT VALIDATION
    Given the third-party submission was accepted via dispute override and routed to manual handling
    Then no automated payment flow should be triggered
    And the case should be in manual review status

Expected Results:
