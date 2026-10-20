Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01)
Then user selects English
Then chatbot asks "How can I help you today?"
And the user says "I'm from a claims company following up on a flight disruption claim for a passenger"
When the chatbot identifies flight disruption intent
Then the chatbot checks: Is this a third-party submission? ? YES
Then the chatbot identifies third-party type ? Claims Company

CLAIM OPENED CHECK:
Then the chatbot asks: "Has a claim been opened by the passenger?"
And the user responds: "Yes"

CASE NUMBER COLLECTION:
Then the chatbot responds: "Please provide a case number and the name of one of the passengers on the claim."
And the user provides: Case number "CLM-77889" and passenger name "Fran�ois Bergeron"

CS LOOKUP:
Then the system checks if the claim exists in Case Services ? YES (found)

30-DAY CHECK:
Then the system checks: Has the case been opened for more than 30 days? ? NO (15 days old)

RESOLUTION CHECK:
Then the system checks: Was there a resolution on the case? ? NO

WAIT MESSAGE:
Then the chatbot responds: "Please wait for the resolution on the case. The passenger should receive an email within 30 days of the case opening."

USER ACCEPTS:
And the user responds: "Okay, we'll wait"

END FLOW (GLOB-11):
Then the chatbot offers: "Is there anything I can help you with?"
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given the system correctly identifies the third-party as a Claims Company
    And the claim has been opened as YES
    And the case number "CLM-77889" and passenger name "Fran�ois Bergeron" have been collected
    And the CS lookup returns FOUND
    And the case has been opened for 15 days which is less than 30 days
    And there is no resolution on the case
    Then the system should display the wait message "Please wait for the resolution on the case. The passenger should receive an email within 30 days of the case opening."
    And the user accepts the wait message
    And the flow should end with no manual handoff
    And no new case should be created in Claims Dashboard
    And the existing case should remain unchanged in Claims Dashboard
    And when searching Claims Dashboard by case number "CLM-77889" only the original case should exist with no new entries

PAYMENT VALIDATION
    Given the existing case is still within the 30-day SLA and the user accepted the wait message
    Then no payment flow should be triggered
    And no new compensation record should have been created
    And no new batch file should have been dispatched
    And no country of residence should have been asked
    And no payment method should have been determined
    And no IDV should have been triggered
    And no CyberSource fraud screening should have been triggered
    And the original case's compensation status should remain unchanged
    And no new Claims Dashboard entry should exist for this third-party follow-up

Expected Results:
