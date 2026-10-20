Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01)
Then user selects English
Then chatbot asks "How can I help you today?"
And the user says "I represent a claims company and I need to file a flight disruption claim for a passenger"
When the chatbot identifies flight disruption intent
Then the chatbot checks: Is this a third-party submission? ? YES
Then the chatbot identifies third-party type ? Claims Company

CLAIM OPENED CHECK:
Then the chatbot asks: "Has a claim been opened by the passenger?"
And the user responds: "Yes"

CASE NUMBER COLLECTION:
Then the chatbot responds: "Please provide a case number and the name of one of the passengers on the claim."
And the user provides: Case number "CLM-11223" and passenger name "Sophie Lef�vre"

CS LOOKUP:
Then the system checks if the claim exists in Case Services ? NO (not found)

COUNTRY OF ORIGIN:
Then the chatbot asks: "From which country did the person you are claiming for originate?"
And the user provides: "France"

MANUAL HANDOFF � INFO COLLECTION:
Then the chatbot responds: "Thanks, a few questions for me to forward your claim: Please provide the name of claims company, ticket number, booking reference, contact information for the passenger, full passenger names for your claim. You'll also need to upload the power of attorney or notice of authorization to have your claim actioned." And the user provides all required information

CASE SENT FOR MANUAL HANDLING:
Then the system creates a case and routes it for manual handling

END FLOW (GLOB-11):
Then the chatbot offers: "Is there anything I can help you with?"
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given the system correctly identifies the third-party as a Claims Company
    And the claim has been opened as YES
    And the CS lookup returns NOT FOUND
    And the country is "France" which is EU-eligible
    Then the system should prompt for claims company name and ticket number and booking reference and passenger contact info and full passenger names and power of attorney or authorization upload
    And a case should be created and routed for manual handling
    And the Claims Dashboard should show case status as "manual review" with third-party type "Claims Company"

PAYMENT VALIDATION
    Given the third-party submission was accepted for EU-eligible country and routed to manual handling
    Then no automated payment flow should be triggered
    And the case should be in manual review status
    And any payment should be determined by the reviewing agent

