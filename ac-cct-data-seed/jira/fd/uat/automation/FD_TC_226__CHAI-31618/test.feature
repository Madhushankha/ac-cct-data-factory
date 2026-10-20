Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01)
Then user selects English
Then chatbot asks "How can I help you today?"
And the user says "My 14-year-old child traveled as an unaccompanied minor and their flight was disrupted. I need to file a claim."
When the chatbot identifies flight disruption intent
Then the chatbot checks: Is this a third-party submission? ? YES
Then the chatbot identifies third-party type ? Parent/Guardian (UMNR/Minor)

OTP AUTHENTICATION:
Then the chatbot initiates OTP verification
And the user provides the correct OTP code

OTP PASSED:
Then the system validates OTP ? PASSED

CLAIM PROCEEDS (AUTOMATED):
Then the chatbot allows the parent to proceed with the flight disruption claim through the regular automated regulation tree

END FLOW (GLOB-11):
Then the chatbot offers: "Is there anything I can help you with?"
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given the system correctly identifies the third-party as "Parent/Guardian" claiming for a Minor or UMNR
    And OTP authentication has been initiated
    And the user provides the correct OTP code
    And the system validates OTP as PASSED
    Then the claim should proceed through the regular automated regulation tree
    And the case should be created and processed automatically
    And no manual handoff should be required
    And the Decision Assist Panel should auto-appear for FD topic
    And DDS should have run automatically
    And the eligibility decision should be pre-populated based on the applicable regime and delay tier
    And the Duplicate Check should have run automatically and the result should be "No duplicate found"
    And the CyberSource result should be "GREEN"
    And the system should have appended the booking record automatically
    And the passenger type should be logged as "Minor" or "UMNR" in the Audit Log
    And the third-party type "Parent/Guardian � OTP Passed � UMNR/Minor" should be logged in the Audit Log
    And an eligible or not eligible notification email should have been sent via Adobe based on the DDS result
    And the Final Status should reflect the DDS outcome
    And the case should be in read-only mode after resolution

PAYMENT VALIDATION
    Given the third-party type is "Parent/Guardian" claiming for a Minor or UMNR
    And OTP authentication has PASSED
    And the claim proceeds through the regular automated regulation tree as if submitted by the passenger
    Then the payment flow should follow the standard FD compensation process identical to a direct passenger submission
    And the country of residence prompt should be displayed to the parent acting on behalf of the minor
    And the system should determine currency and payment method based on the passenger's country of residence
    And if the passenger's country of residence is "Canada" then the currency should be set to "CAD" and the payment method should be "Interac e-Transfer"
    And if the passenger's country of residence is an EU country then the currency should be set to "EUR" or "GBP" as applicable and the payment method should be "BSM � Email Payment"
    And if the passenger's country of residence is "Israel" then the currency should be set to "ILS" and the payment method should be "BSM � Email Payment"
    And the Cash vs AC Wallet check should be performed based on whether the minor passenger has an Aeroplan number linked to the booking
    And if no Aeroplan is linked then only Cash should be offered with no AC Wallet option
    And if Aeroplan is linked and account is active and not frozen then BOTH Cash and AC Wallet with 20% top-up should be offered
    And the compensation amount should be determined by the applicable regime and delay tier as per the standard regulation tree
    And for APPR the compensation should be $400 CAD for Tier 1 3 to less than 6hrs or $700 CAD for Tier 2 6 to less than 9hrs or $1,000 CAD for Tier 3 9hrs or more
    And for EU 261 the compensation should follow the distance band and delay thresholds as per standard EU 261 rules
    And for ASL the compensation should follow the ASL fixed rate schedule
    And for dual or triple regime scenarios the fixed priority hierarchy should apply as per standard regime selection rules
    And the compensation amount for a minor or UMNR should be the SAME as for an adult passenger as APPR and EU 261 and ASL do not differentiate compensation by passenger age
    And IDV at Payment should be triggered via Persona and the parent should complete IDV on behalf of the minor and Persona should return IDV PASS
    And the Interac e-Transfer email or BSM email should be collected from the parent as the minor may not have their own email or bank account
    And a compensation record should be created in the backend with GL account and cost center
    And in UAT the batch file should be triggered manually in coordination with the Unifier or SAP team
    And if payment method is Interac e-Transfer then Cash should be dispatched to Unifier and Unifier should process the Interac e-Transfer to the parent's confirmed email address
    And if payment method is BSM Email Payment then Cash should be dispatched to Unifier via HSBC channel for BSM
    And if payment method is AC Wallet then the compensation record should be picked up by the daily evening batch file and dispatched to EIP not Unifier
    And Unifier or EIP should send an acknowledgement back
    And the end-of-day report should show status "Pending" transitioning to "Cached" or "Rejected" or "Expired" or "Completed"
    And if payment method is Interac e-Transfer and unclaimed after 35 days the status should be Expired
    And if payment fails a failure notification should be sent to the case and the agent should be flagged
    And the Claims Dashboard Compensation tab should show payout details with the correct amount and currency and payment method and status updated via talkback
    And the passenger type should be logged as "Minor" or "UMNR" in the Audit Log
    And the third-party type "Parent/Guardian � OTP Passed � UMNR/Minor" should be logged in the Audit Log but should NOT affect the compensation amount or payment method or processing path
    And the payment flow should be identical to a direct adult passenger submission with the only difference being the Interac or BSM email may belong to the parent rather than the minor
    And if the system erroneously blocks payment or routes to manual handling due to the minor or UMNR flag despite OTP PASS this is a P1 defect as OTP pass for UMNR or Minor equals full automation
    And if the system erroneously reduces the compensation amount for a minor this is a P1 defect as compensation is not age-dependent under any applicable regime

Expected Results:
