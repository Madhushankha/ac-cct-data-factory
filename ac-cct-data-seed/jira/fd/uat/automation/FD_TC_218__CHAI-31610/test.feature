Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01)
Then user selects English
Then chatbot asks "How can I help you today?"
And the user says "I'm from a claims company, we need an update on a flight disruption claim"
When the chatbot identifies flight disruption intent
Then the chatbot checks: Is this a third-party submission? ? YES
Then the chatbot identifies third-party type ? Claims Company

CLAIM OPENED CHECK:
Then the chatbot asks: "Has a claim been opened by the passenger?"
And the user responds: "Yes"

CASE NUMBER COLLECTION:
Then the chatbot responds: "Please provide a case number and the name of one of the passengers on the claim."
And the user provides: Case number "CLM-99001" and passenger name "�milie Gagnon"

CS LOOKUP:
Then the system checks if the claim exists in Case Services ? YES (found)

30-DAY CHECK:
Then the system checks: Has the case been opened for more than 30 days? ? NO (20 days old)

RESOLUTION CHECK:
Then the system checks: Was there a resolution on the case? ? NO

WAIT MESSAGE:
Then the chatbot responds: "Please wait for the resolution on the case. The passenger should receive an email within 30 days of the case opening."

USER DISPUTES:
And the user responds: "This is unacceptable, we need this escalated immediately"

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
    Given the system correctly identifies the third-party as a Claims Company
    And the claim has been opened as YES
    And the case number "CLM-99001" and passenger name "�milie Gagnon" have been collected
    And the CS lookup returns FOUND
    And the case has been opened for 20 days which is less than 30 days
    And there is no resolution on the case
    Then the system should display the wait message "Please wait for the resolution on the case. The passenger should receive an email within 30 days of the case opening."
    And the user disputes the wait message
    Then the system should override and proceed to manual handoff
    And the system should collect claims company name and ticket number and booking reference and contact information for the passenger and full passenger names and power of attorney or authorization upload
    And the user provides all required information
    And a case should be created or updated and routed for manual handling
    And the Claims Dashboard should show the case routed for manual review with the dispute override noted in the audit log

PAYMENT VALIDATION
    Given the existing case was within the 30-day SLA but the user disputed and the case was escalated to manual handoff
    Then no automated payment flow should be triggered
    And no country of residence should have been asked during the chatbot flow
    And no compensation record should have been created automatically
    And no batch file should have been dispatched
    And no IDV should have been triggered
    And no CyberSource fraud screening should have been triggered
    And the case should be in manual review status
    And if the agent later determines eligible manual compensation should be created and payment dispatched per type with cash to Unifier and e-credit to EIP
    And the Claims Dashboard should show case status as "Manual Review" with no payout section until manually resolved

Expected Results:
