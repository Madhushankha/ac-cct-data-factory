Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "I'm a travel agent and I need to file a flight disruption claim on behalf of my client. Their flight from Montreal to Toronto was delayed 7 hours due to crew transport delays and they have an Aeroplan membership."
When the chatbot identifies flight disruption intent
Then the chatbot checks: Is this a third-party submission? ? YES
Then the chatbot identifies third-party type ? TRAVEL AGENCY

THIRD-PARTY TYPE CHECK:
Then the system evaluates: Caller type = Travel Agency
And the system checks: Is Travel Agency an accepted third-party submission type? ? NO (hard rejection per policy)
And the system determines: NO override path exists for Travel Agencies
And the system determines: Flight details (Code 67, 7h delay, APPR, Basic Aeroplan) are irrelevant to the rejection � policy is absolute

REJECTION (3P-REJECT-01):
Then the chatbot responds:
"Thank you for contacting Air Canada. We appreciate you reaching out on behalf of your client. However, under Air Canada's passenger compensation policy, flight disruption claims under the Air Passenger Protection Regulations (APPR) must be submitted directly by the affected passenger. Travel agencies and other third-party representatives are not permitted to file these claims on a passenger's behalf. Please advise your client to contact us directly through our website or by calling our Customer Relations team to submit their claim. We apologize for any inconvenience."

NO IDENTIFICATION STEP (skipped � rejected before any info collection)
NO AUTHENTICATION STEP (skipped � rejected before OTP or IDV)
NO PASSENGER SELECTION (skipped)
NO JOURNEY SELECTION (skipped)
NO DUPLICATE CHECK (skipped)
NO DDS EVALUATION (skipped � despite valid APPR Code 67 7h claim)
NO PAYMENT FLOW (skipped)
NO FRAUD SCREENING (skipped)
NO CASE CREATION (skipped)
NO AEROPLAN CHECK (skipped � Basic Aeroplan 9876543210 not evaluated)
NO AC WALLET OFFER (skipped � not reached)

NOTE � CRITICAL VALIDATION POINT:
? Underlying flight = Code 67 (Crew Transport � Controllable), 7h delay (6�<9h band)
? APPR Tier 2 baseline = $700 CAD Cash / $840 CAD AC Wallet (Basic Aeroplan linked)
? Under normal passenger submission, this would be a fully ELIGIBLE, auto-approved case
? HOWEVER: Travel Agency submission type = hard rejection, no exceptions, no override
? The validity and eligibility of the underlying claim does NOT affect the rejection outcome

END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given the system correctly identifies the third-party type as "Travel Agency"
    Then the system should immediately reject the submission at the third-party check gate
    And the rejection should occur BEFORE any of the following steps:
    ? Identification / name collection
    ? PNR lookup
    ? OTP / authentication
    ? Passenger selection
    ? Journey selection (Code 67 / 7h delay / APPR details not evaluated by DDS)
    ? Aeroplan validation (Basic Member 9876543210 not checked)
    ? Duplicate check
    ? DDS evaluation
    And the rejection message should clearly state the customer must submit the claim themselves
    And no case should be created in Claims Dashboard
    And when searching Claims Dashboard no entry should exist for this Travel Agency submission
    And no manual handoff should occur
    And the flow should end after the rejection message
    And no country of residence should have been collected
    And no Aeroplan or profile lookup should have been performed
    And no compensation record should exist
    And Travel Agencies are always denied per policy with no country-based, Aeroplan-based, or dispute override path

PAYMENT VALIDATION
    Given the Travel Agency submission was hard rejected per policy
    Then no payment flow should be triggered
    And no case should exist in Claims Dashboard
    And no compensation record should have been created
    And no batch file should have been dispatched
    And no country of residence should have been asked
    And no Aeroplan or AC Wallet evaluation should have been triggered (Basic Aeroplan 9876543210 not reached)
    And no IDV should have been triggered
    And no CyberSource fraud screening should have been triggered
    And the underlying APPR claim data (Code 67, 7h delay, Tier 2, $700 CAD / $840 AC Wallet) is irrelevant to the outcome � Travel Agency = hard rejection, no exceptions

Expected Results:
System correctly identifies third-party type as Travel Agency. System immediately rejects at third-party gate BEFORE identification, PNR lookup, authentication, journey selection, or DDS evaluation. Rejection message clearly states the customer must submit the claim themselves. CRITICAL: Even though the underlying flight involves a valid controllable APPR claim (Code 67 Crew Transport, 7h delay, 6�<9h band, $700 CAD Tier 2 / $840 CAD AC Wallet for Basic Aeroplan member 9876543210), the Travel Agency submission is a hard rejection � no override path, no country-based exception, no Aeroplan-based exception. No case created. No manual handoff. No compensation record. Flow ends cleanly after rejection.