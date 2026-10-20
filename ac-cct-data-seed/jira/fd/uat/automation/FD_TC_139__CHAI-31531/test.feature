Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "I was denied boarding on my flight from Paris to Toronto even though I had a valid ticket and was at the gate on time. Can I get compensation?"
When the chatbot identifies flight disruption intent
Then the chatbot checks: Is this a denied boarding event? ? YES
DENIED BOARDING REDIRECT:
Then the chatbot responds:
"I understand you were denied boarding on your flight. I'm sorry for the inconvenience. Denied boarding claims are handled through a separate process. Please contact our Customer Relations team directly or visit our website to submit a denied boarding claim. They will be able to assist you with your specific situation."
And the chatbot provides:
� Customer Relations contact information
� Link to denied boarding claim form
� Reference to EU 261 denied boarding rights
NO IDENTIFICATION FLOW (skipped � denied boarding redirect)
NO AUTHENTICATION FLOW (skipped)
NO DDS EVALUATION (skipped � separate process)
NO PAYMENT FLOW (skipped)
NO IDV (skipped)
NO FRAUD SCREENING (skipped)
NO CASE CREATION (no automated case � denied boarding handled separately)
END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
  Given the claimant "Sophie Laurent" was identified and authenticated for PNR "TC098" (Auth Flow 1)
  And DDS detected a denied boarding event on the MSL with booking flag "VOL-DB"
  Then exactly one case should have been created for claimant "Sophie Laurent" with PNR "TC098"
  And the Case Header Topic/Sub-topic should be "Travel Disruptions � Denied Boarding"
  And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
  And the Case Status should be "Closed � Not Eligible"
  And the Created date and Last Updated date should be populated
  And the SLA countdown should be tracking correctly
  And the Team assignment should be correct
  And no banners should be displayed for identified and authenticated Auth Flow 1 user
  And the Decision Assist panel should NOT be greyed out
  And the Claimant Name should be "Sophie Laurent"
  And the Claimant Type should be "Adult"
  And the Authentication should be "Pass"
  And the PNR should be "TC098"
  And the PNR Creation Date, Journey ID, Booking Source and Booking Office ID should be populated
  And the Operating Carrier should be "Air Canada (AC)"
  And the Regime should be "EU 261 (UK)"
  And the Full Name should be "Sophie Laurent"
  And the Tags should include "Claimant" and "Adult"
  And the Email, Phone, Address and Profile ID should be populated
  And the Journey should show "Bound 1: LHR ? YYZ" with the original flight (scheduled departure 10:00) and the next flight (departed 14:00, arrived 18:00)
  And the Denied Boarding Type should be "VOLUNTARY"
  And the VOL-DB flag should be "TRUE"
  And the airline offer should be shown as "Accepted � EUR 200 voucher + next flight"
  And the Ancillary Fee section should be present with no expected ancillary fees
  And the Eligibility and Compensation section should show "NOT ELIGIBLE (Flight Disruption) � Voluntary Denied Boarding � GBP 0"
  And no EU 261 compensation amount (GBP 520 / EUR 600) should be calculated or shown on top of the voluntary offer
  And the 4-hour later arrival should NOT be used to calculate delay compensation
  And the Decision Assist Panel should auto-appear for FD topic
  And DDS should have run automatically with no agent action needed
  And the DDS outcome should be "FD-EU-NE-06"
  And the eligibility decision should be pre-populated as "NOT ELIGIBLE" with reason "Voluntary Denied Boarding � customer accepted airline offer"
  And the Duplicate Check should have run automatically using baseline data "Sophie Laurent + TC098 + LHR?YYZ + FD"
  And the result should be "No duplicate found"
  And no Duplicate Warning Banner should be displayed
  And the Related Cases tab should show no related cases
  And the CyberSource result should be "Not triggered"
  And the Persona IDV status should be "Not triggered"
  And no manual-review queue item should exist for this case
  And the system should have appended the booking record automatically for identified and authenticated user
  And Trip Tracer poll should NOT be required
  And a not eligible notification email should have been sent via Adobe stating the reason (voluntary denied boarding, airline offer accepted)
  And the email should NOT contain any compensation amount
  And the Agent Notes section should be accessible
  And the Audit Log should record the VOL-DB detection and the Not Eligible decision with timestamps and before/after values
  And Customer Communications should show the not eligible email chronologically
  And the chatbot transcript should be accessible and linked to the case
  And the Attachments tab should be empty
  And the Final Status should be "Closed � Not Eligible"
  And the case should be in read-only mode with no editable Decision Assist fields
  And the agent should not be able to access Case Search as it is for leads and management only

PAYMENT VALIDATION
    Given no case was created due to denied boarding being handled separately
    Then no payment flow should be triggered
    And no country of residence should have been asked
    And no compensation record should have been created
    And no batch file should have been dispatched
    And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section

Expected Results:
DDS returns FD-EU-NE-05. Trip Tracer: Original flight = LHR?YYZ 10:00; Customer voluntarily denied boarding; Accepted compensation offer (�200 voucher); Rebooked on next flight arriving 4hrs later; Denied Boarding Type = VOLUNTARY. CRITICAL: Voluntary denied boarding = customer chose to give up seat ? NOT eligible for additional EU 261 compensation. The airline's offer (�200 voucher) is the agreed compensation. DDS must NOT calculate additional �600 on top of the voluntary offer. Compensation under EU 261: $0 � Not Eligible (voluntary DB). Claims Dashboard: Not Eligible; Reason = Voluntary Denied Boarding; VOL-DB flag = TRUE; Airline offer accepted; DDS = FD-EU-NE-05.