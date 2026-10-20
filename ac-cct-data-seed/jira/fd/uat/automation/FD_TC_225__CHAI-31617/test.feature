Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01)
Then user selects English
Then chatbot asks "How can I help you today?"
And the user says "I'm an insurer and I need to file a disruption claim for one of our policyholders"
When the chatbot identifies flight disruption intent
Then the chatbot checks: Is this a third-party submission? ? YES
Then the chatbot identifies third-party type ? Insurer/FI

DOCUMENT UPLOAD REQUIRED:
Then the chatbot responds: "To proceed with your claim, you'll need to upload a document proving you have the authority to act on behalf of the passenger."

USER CANNOT PROVIDE:
And the user responds: "I don't have a power of attorney document right now"

DENIAL:
Then the chatbot responds: "We're unable to process a claim on behalf of a passenger without proper documentation proving your authority to act on their behalf. Please obtain the necessary authorization documents and try again."

END FLOW (GLOB-11):
Then the chatbot offers: "Is there anything I can help you with?"
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given the system correctly identifies the third-party as "Insurer/FI"
    And the document upload has been requested
    And the user cannot provide a power of attorney document
    Then the system should deny the claim with a clear message explaining documentation is required
    And no case should be created in Claims Dashboard
    And no manual handoff should occur
    And the flow should end
    And when searching Claims Dashboard no entry should exist for this submission

PAYMENT VALIDATION
    Given the Individual with POA submission was denied due to no documentation provided
    Then no payment flow should be triggered
    And no case should exist in Claims Dashboard
    And no compensation record should have been created
    And no batch file should have been dispatched
    And no country of residence should have been asked
    And no IDV should have been triggered
    And no CyberSource fraud screening should have been triggered

Expected Results:
