Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01)
Then user selects English
Then chatbot asks "How can I help you today?"
And the user says "I'm the legal guardian of a minor and I need to submit a flight disruption claim on their behalf"
When the chatbot identifies flight disruption intent
Then the chatbot checks: Is this a third-party submission? ? YES
Then the chatbot identifies third-party type ? Legal/Guardian/Tutor/Insurer/FI

DOCUMENT UPLOAD REQUIRED:
Then the chatbot responds: "To proceed with your claim, you'll need to upload a document proving you have the authority to act on behalf of the passenger (e.g., Power of Attorney, guardianship order, authorization letter)."
And the chatbot collects: ticket number, booking reference, contact information for the passenger, full passenger names, and requests document upload
And the user uploads the guardianship document and provides required information

CASE SENT FOR MANUAL HANDLING:
Then the system creates a case and routes it for manual handling

END FLOW (GLOB-11):
Then the chatbot offers: "Is there anything I can help you with?"
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given the system correctly identifies the third-party as "Legal/Guardian/Tutor/Insurer/FI"
    And no OTP path should be offered as this is not Family/Friend
    Then the system should go directly to the document upload requirement
    And the system should collect ticket number and booking reference and contact information for the passenger and full passenger names and request POA or guardianship or authorization document upload
    And the user uploads the guardianship document and provides required information
    And a case should be created and routed for manual handling with intake approval flag
    And the Claims Dashboard should show the case with third-party type "Legal/Guardian/Tutor/Insurer/FI" and status "Manual Review" and intake approval required

PAYMENT VALIDATION
    Given the Individual with POA submission was routed to manual handling
    Then no automated payment flow should be triggered
    And no country of residence should have been asked during the chatbot flow
    And no compensation record should have been created automatically
    And no batch file should have been dispatched
    And no IDV should have been triggered via the automated flow
    And no CyberSource fraud screening should have been triggered via the automated flow
    And the case should be in manual review status with intake approval required
    And if the agent later approves intake and determines eligible manual compensation should be created and payment dispatched per type with cash to Unifier and e-credit to EIP
    And the Claims Dashboard should show case status as "Manual Review � Intake Approval Required" with no payout section until manually resolved
    And no automated path exists for this third-party category per policy

Expected Results:
