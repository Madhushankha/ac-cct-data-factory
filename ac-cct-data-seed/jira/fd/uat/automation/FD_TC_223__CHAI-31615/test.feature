Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01)
Then user selects English
Then chatbot asks "How can I help you today?"
And the user says "I'm filing a flight disruption claim for my elderly mother who can't use the computer"
When the chatbot identifies flight disruption intent
Then the chatbot checks: Is this a third-party submission? ? YES
Then the chatbot identifies third-party type ? Parent/Guardian/Family/Friend

OTP AUTHENTICATION:
Then the chatbot initiates OTP verification
And the user responds: "She doesn't have access to her phone right now, I can't get the code"

OTP FAILED:
Then the system marks OTP ? FAILED / NOT COMPLETED

DOCUMENT UPLOAD REQUIRED:
Then the chatbot responds: "Since we're unable to verify through OTP, you'll need to upload a document proving you have the authority to act on behalf of the passenger (e.g., Power of Attorney, authorization letter)."
And the chatbot collects: ticket number, booking reference, contact information for the passenger, full passenger names, and requests document upload
And the user uploads the authorization document and provides required information

CASE SENT FOR MANUAL HANDLING:
Then the system creates a case and routes it for manual handling (intake approval required)

END FLOW (GLOB-11):
Then the chatbot offers: "Is there anything I can help you with?"
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given the system correctly identifies the third-party as "Parent/Guardian/Family/Friend"
    And OTP authentication has been initiated
    And the user cannot provide the correct OTP code as the passenger is unreachable
    And the system marks OTP as FAILED or NOT COMPLETED
    Then the system should fall back to the document upload path
    And the system should collect ticket number and booking reference and contact information for the passenger and full passenger names and request POA or authorization document upload
    And the user uploads the authorization document and provides required information
    And a case should be created and routed for manual handling with intake approval flag
    And the Claims Dashboard should show the case with third-party type "Family/Friend � OTP Failed" and status "Manual Review" and intake approval required

PAYMENT VALIDATION
    Given the Family/Friend OTP failed and the case was routed to manual handling with POA upload
    Then no automated payment flow should be triggered
    And no country of residence should have been asked during the chatbot flow
    And no compensation record should have been created automatically
    And no batch file should have been dispatched
    And no IDV should have been triggered via the automated flow
    And no CyberSource fraud screening should have been triggered via the automated flow
    And the case should be in manual review status with intake approval required
    And if the agent later approves intake and determines eligible manual compensation should be created and payment dispatched per type with cash to Unifier and e-credit to EIP
    And the Claims Dashboard should show case status as "Manual Review � Intake Approval Required" with no payout section until manually resolved

Expected Results:
