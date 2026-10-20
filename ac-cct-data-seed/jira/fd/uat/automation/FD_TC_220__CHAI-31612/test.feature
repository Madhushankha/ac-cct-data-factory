Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01)
Then user selects English
Then chatbot asks "How can I help you today?"
And the user says "I'm calling from a travel agency, my elderly client cannot file the claim themselves and I need to do it for them"
When the chatbot identifies flight disruption intent
Then the chatbot checks: Is this a third-party submission? ? YES
Then the chatbot identifies third-party type ? Travel Agency

INITIAL REJECTION:
Then the chatbot responds advising the customer must submit the claim themselves.

USER DISPUTES:
And the user responds: "My client is elderly and unable to use the system, I have their authorization to act on their behalf"

SYSTEM RESPONSE:
Then the chatbot either: (a) Maintains rejection and reiterates that the customer must submit the claim, OR (b) Escalates to manual handoff by collecting required information (claims company name, ticket number, booking reference, contact info, passenger names, power of attorney/authorization)

END FLOW (GLOB-11):
Then the chatbot offers: "Is there anything I can help you with?"
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given the system correctly identifies the third-party type as "Travel Agency"
    And the initial rejection is displayed advising the customer must submit the claim themselves
    And the user disputes the rejection citing the passenger is elderly and unable to use the system
    Then the system should either maintain the hard rejection and reiterate that the customer must submit the claim themselves OR escalate to manual handoff by collecting required information including claims company name and ticket number and booking reference and contact info and passenger names and power of attorney or authorization
    And the actual system behavior should be documented for UAT validation
    And if the system maintains rejection then no case should be created and no manual handoff should occur
    And if the system escalates then a case should be created and routed for manual handling

PAYMENT VALIDATION
    Given the Travel Agency submission was either maintained as rejected or escalated to manual handoff after dispute
    Then no automated payment flow should be triggered regardless of the dispute outcome
    And no country of residence should have been asked during the chatbot flow
    And no compensation record should have been created automatically
    And no batch file should have been dispatched
    And no IDV should have been triggered
    And no CyberSource fraud screening should have been triggered
    And if the system maintained rejection then no case should exist and no payment is possible
    And if the system escalated to manual handoff then any payment should be determined by the reviewing agent and the Claims Dashboard should show case status as "Manual Review" with no payout section until manually resolved

Expected Results:
