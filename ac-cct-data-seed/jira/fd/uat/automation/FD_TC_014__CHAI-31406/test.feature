Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My family's flight was delayed 4 hours, there are 3 of us on the booking, we all want compensation"
When the chatbot identifies flight disruption intent
Then the chatbot checks: Is this a third-party submission? ? NO
Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation."

LEGAL DISCLAIMER:
Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need your booking reference, the name associated to the booking and any receipts you'd like to be reimbursed for. If your claim is eligible, you may also need to provide your address, contact information and where you'd like the funds deposited. Would you like to get started?"

IDENTIFICATION (GenUC-01):
Then the chatbot responds:
"I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you."
And the chatbot responds:
"Please provide your full name exactly as it appears on your ticket, including any middle names if applicable."
And the user provides "Catherine Bouchard"
Then the chatbot responds:
"Thanks, Catherine! And, what is your booking reference number?"
And the user provides "PNR: TC012"
Then the chatbot searches Trip Tracer for PNR: TC012
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer

AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
� Email: c***@gmail.com
� Phone: +1***123
And the user selects "Email: c***@gmail.com"
Then the chatbot responds:
"I've sent a verification code to your email, please enter it within 15 minutes of receiving it."
And the user provides the OTP code "629481"
Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5)
Then the chatbot responds:
"Your verification was successful. Let's proceed to the next step."

GROUP BOOKING CHECK:
Then the system checks Trip Tracer for group booking identifier
And group booking identifier = NOT PRESENT
And system proceeds to passenger selection

PASSENGER SELECTION (GenUC-06):
Then the chatbot asks:
"How many people are on your claim?"
And the chatbot displays passengers from PNR:
"I found 3 passengers on this booking:
� Catherine Bouchard (Adult)
� Marc Bouchard (Adult)
� Sophie Bouchard (Adult)
Which passengers would you like to include?"
And the user selects all 3 passengers: "All of them"
Then the chatbot checks: PAX count on PNR = 3 ? ?9 ? NOT a group booking ? PROCEED
Then the chatbot confirms: "I'll include all 3 passengers in this claim: Catherine Bouchard, Marc Bouchard, and Sophie Bouchard."

JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
� Flight: AC 424
� Route: Montreal (YUL) ? Toronto (YYZ)
� Date: May 15, 2026
� Arrival Delay: 4 hours
Is this the journey you'd like to check?"
And the user confirms "Yes"

SEGMENT CHECK:
Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18

DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for these passengers + journey combination

72-HOUR CHECK:
Then the chatbot checks: Hours since last leg arrival
And the system calculates: Arrival was May 15, 2026; current date is June 4, 2026 ? >72 hours ? PROCEED

CLAIM TIME LIMIT CHECK:
Then the chatbot checks: Filing deadline for APPR = 366 days from disruption
And the system calculates: Disruption May 15, 2026; filing June 4, 2026 ? within 366 days ? PROCEED

TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS Evaluates and sends to Trip Tracer UI:

TRIP TRACER UI VALIDATION
Then the tester opens Trip Tracer UI for PNR: TC011
? Promised Itinerary - Flight: AC 424, Route: YUL ? YYZ, Scheduled Arrival: 14:00 (14-day mark)
? Current Itinerary - Flight: AC 424, Route: YUL ? YYZ, Status: ARRIVED LATE, Scheduled Arrival: ~~14:00~~ ? Actual: 18:00, Delay: +4H 00M
? History - No changes recorded
? Regime: APPR (1 regime)
? MSL FLIGHT: AC 424 � YUL ? YYZ � 56
? "Delayed due to crew legality"
? Delay: +4H 00M � CONTROLLABLE
Flight Compensation:
  ? MS CATHERINE BOUCHARD | ELIGIBLE | DELAY_3_TO_LT_6_HOURS | CAD 400.00 | [expiry date]
  ? MR MARC BOUCHARD | ELIGIBLE | DELAY_3_TO_LT_6_HOURS | CAD 400.00 | [expiry date]
  ? MS SOPHIE BOUCHARD | ELIGIBLE | DELAY_3_TO_LT_6_HOURS | CAD 400.00 | [expiry date]

FRAUD SCREENING � CYBERSOURCE (GLOB-05):
Then the chatbot sends case details to CyberSource for fraud screening
And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected)
And the customer is cleared to proceed to payment

ELIGIBLE RESULT (FD-05a):
Then the chatbot displays:
"I've checked your flight details, and it looks like flight AC 424 from Montreal (YUL) to Toronto (YYZ) was delayed by about 4 hours. Based on the Air Passenger Protection Regulations (APPR), all 3 passengers may be eligible for compensation for this delay. I'll guide you through the next steps so we can get your claim submitted and processed as quickly as possible."

CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW:
Then the chatbot asks:
"Thank you for confirming. In which country will your reimbursement be deposited?"
And the user selects "Canada"
Then the system determines: Country = Canada ? Currency = CAD

CASH vs AC WALLET CHECK (FD-06b):
Then the chatbot checks: Does customer have Aeroplan number on booking? ? No
Then the chatbot checks if the claim is for multiple pax ? Yes (3 passengers)
Then the chatbot responds: "Each passenger is entitled to receive $400 CAD compensation, for a total of $1,200 CAD for all 3 passengers. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed?"
And an alert information is displayed: "Please note that payments will be deposited in your local currency."
And user provides "Yes"
Then system checks which payment method is mapped based on country of residence ? Interac (CANADA)

PAYMENT METHOD � INTERAC (FD-07):
Then the chatbot responds:
"Your payment will be made through Interac e-transfer. Before we move forward, please confirm the email address where you'd like to receive your payment related information. Would you like to use c***@gmail.com? Please note that only one email address can be used for this compensation/reimbursement and it can't be changed once confirmed."
And the user confirms "Yes, use this email"
Then system checks that IDV is not completed

IDENTITY VERIFICATION � PERSONA (FD-07b):
Then the chatbot responds:
"I must verify your identity for payment security. Please click here to get started"
And chatbot displays a button "Get verified"
When user clicks on the button
Then system checks if IDV at Payment
Then system checks if user have consented to IDV
And the chatbot sends Persona IDV link to the customer
And the customer opens the Persona link
And the customer completes identity verification via Persona
And Persona returns: IDV PASS
Then the chatbot responds:
"Your identity has been verified successfully. Let's proceed to finalize your claim."

CLAIM AMOUNT CONFIRMATION:
Then the chatbot responds: "Please review your compensation details:
Passengers: Catherine Bouchard, Marc Bouchard, Sophie Bouchard
Deposit Amount: $1,200 CAD ($400 � 3 passengers)
Payment Method: c***@gmail.com
After submission, you will receive a confirmation email summarizing your eligibility, claim details and next steps that will also include the password required to access the secure payment link, which will be sent in a separate email
Would you like me to submit your claim?"
And an alert information is displayed: "Please note that the payment details cannot be changed after submission."
When the user provides: "Yes"

CASE CREATION (GLOB-09):
Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your claim details, and a second email that will include the secure link where you'll provide your information."
And an alert information is displayed: "Claim submission successful!"
And the system appends the booking record to the case automatically

NOTIFICATION (Adobe):
Then the system triggers notification via Adobe:
And an eligible notification email is sent to c***@gmail.com
And the email contains: Case Reference, compensation amount ($1,200 CAD total, $400 per passenger), regulation (APPR), flight details, all 3 passenger names, disruption reason, next steps, tracking link

END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
Feature: Claims Dashboard Validation � TC011 Catherine Bouchard (3 Passengers)

  Scenario: Validate Claims Dashboard for TC011 Catherine Bouchard (3 Passengers)
    Given the case has been created for claimant "Catherine Bouchard" with PNR "TC011" and 3 passengers
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
    And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
    And the Case Status should be "In Review" or "Done"
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be correct
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel should NOT be greyed out
    And the Claimant Name should be "Catherine Bouchard"
    And the Claimant Type should be "Adult"
    And the Authentication should be "Pass"
    And the PNR should be "TC011"
    And the PNR Creation Date should be populated
    And the Journey ID should be populated
    And the Booking Source should be populated
    And the Booking Office ID should be populated
    And the Regime should be "APPR"
    And Passenger 1 Full Name should be "Catherine Bouchard" with Tags "Claimant" and "Adult" and Email "c***@gmail.com" and Phone "+1***123"
    And Passenger 2 Full Name should be "Marc Bouchard" with Tags "Adult"
    And Passenger 3 Full Name should be "Sophie Bouchard" with Tags "Adult"
    And the Address should be populated
    And the Aeroplan should be "Not linked"
    And the Profile ID should be populated
    And the Tier Status should be populated
    And the agent should be able to add or remove passengers from the claim
    And the Journey should show "Bound 1: YUL ? YYZ" with claim filed for this flight
    And the Ancillary Fee section should be present
    And the expected ancillary fees should be none
    And the Eligibility and Compensation section should be present and populated for this automated FD case
    And the Decision Assist Panel should auto-appear for FD topic
    And DDS should have run automatically with no agent action needed
    And the eligibility decision should be pre-populated
    And the Duplicate Check should have run automatically using baseline data "Catherine Bouchard + Marc Bouchard + Sophie Bouchard + TC011 + YUL?YYZ + FD"
    And the result should be "No duplicate found"
    And no Duplicate Warning Banner should be displayed
    And the Related Cases tab should show no related cases
    And the CyberSource result should be "GREEN"
    And the case should have proceeded automatically and not be parked in Fraud Queue
    And the system should have appended the booking record automatically for identified and authenticated user
    And Trip Tracer poll should NOT be required
    And the agent should have used pull case from My Activities
    And the case status should have transitioned from "Assigned" to "In Progress"
    And a case acknowledgement notification should have been sent
    And an eligible notification email should have been sent via Adobe
    And the Agent Notes section should be accessible
    And the Audit Log should record all actions with timestamps and before/after values
    And Customer Communications should show the notification email chronologically
    And the chatbot transcript should be accessible and linked to the case
    And the Attachments tab should be empty
    And the Final Status should be "Resolved"
    And the case should be in read-only mode with no editable Decision Assist fields
    And the agent should not be able to access Case Search as it is for leads and management only


Feature: Payment Validation � TC011 Catherine Bouchard (3 Passengers)

  Scenario: Validate Payment for TC011 Catherine Bouchard (3 Passengers)
    Given the customer's country of residence is "Canada"
    Then the currency should be set to "CAD"
    And the payment method should be "Interac e-Transfer"
    And all 3 passengers are eligible so the aggregated total should be displayed as "$400 x 3 = $1,200"
    And a compensation record should be created in the backend with GL account and cost center
    And in UAT the batch file should be triggered manually in coordination with the Unifier and SAP team
    And Cash should be dispatched to Unifier
    And Unifier should send an acknowledgement back
    And the end-of-day report should be received from Interac
    And the status should be "Pending" transitioning to "Cached" or "Rejected" or "Expired"
    And if the payment is unclaimed after 35 days the status should be set to "Expired"
    And the Claims Dashboard Compensation tab should verify the per-passenger amount
    And the total amount should be displayed
    And the currency should be displayed
    And the payment method should be displayed
    And the status should be updated via talkback


Feature: Claims Dashboard Validation � TC012 Group Booking Redirect

  Scenario: Validate Claims Dashboard for TC012 Group Booking Redirect
    Given the group booking identifier was detected in Trip Tracer for PNR "TC012"
    Then the chatbot should have redirected the customer to Customer Relations via phone, email, or online
    And no passenger selection should have occurred
    And no journey selection should have occurred
    And no DDS evaluation should have occurred
    And no case should have been created in the automated system
    And no Claims Dashboard entry should exist for PNR "TC012"
    And when searching Claims Dashboard by PNR "TC012" no case should be found


Feature: Payment Validation � TC012 Group Booking

  Scenario: Validate Payment for TC012 Group Booking
    Given the group booking allows the customer to claim for self only and passenger selection is skipped
    Then the payment flow should proceed for 1 passenger only
    And the customer's country of residence is "Canada"
    And the currency should be set to "CAD"
    And the payment method should be "Interac e-Transfer"
    And a compensation record should be created
    And the record should be picked up by the daily evening batch file
    And the record should be dispatched to Unifier
    And in UAT the batch file should be triggered manually
    And Unifier should send an acknowledgement back
    And the end-of-day report should be received from Interac
    And the status should be "Pending" transitioning to "Cached" or "Rejected" or "Expired"
    And if the payment is unclaimed after 35 days the status should be set to "Expired"
    And the Claims Dashboard Compensation tab should show payout details for the single claimant only


Feature: Claims Dashboard Validation � TC013 Catherine Bouchard

  Scenario: Validate Claims Dashboard for TC013 Catherine Bouchard
    Given the case has been created for claimant "Catherine Bouchard" with PNR "TC013"
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
    And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
    And the Case Status should be "In Review" or "Done"
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be correct
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel should NOT be greyed out
    And the Claimant Name should be "Catherine Bouchard"
    And the Claimant Type should be "Adult"
    And the Authentication should be "Pass"
    And the PNR should be "TC013"
    And the PNR Creation Date should be populated
    And the Journey ID should be populated
    And the Booking Source should be populated
    And the Booking Office ID should be populated
    And the Regime should be "APPR"
    And the Full Name should be "Catherine Bouchard"
    And the Tags should include "Claimant" and "Adult"
    And the Email should be "c***@gmail.com"
    And the Phone should be "+1***345"
    And the Address should be populated
    And the Aeroplan should be "Not linked"
    And the Profile ID should be populated
    And the Tier Status should be populated
    And the Journey should show "Bound 1: YUL ? YYZ" with claim filed for this flight
    And the Ancillary Fee section should be present
    And the expected ancillary fees should be none
    And the Eligibility and Compensation section should be present and populated for this automated FD case
    And the Decision Assist Panel should auto-appear for FD topic
    And DDS should have run automatically with no agent action needed
    And the eligibility decision should be pre-populated
    And the Duplicate Check should have run automatically using baseline data "Catherine Bouchard + TC013 + YUL?YYZ + FD"
    And the result should be "No duplicate found"
    And no Duplicate Warning Banner should be displayed
    And the Related Cases tab should show no related cases
    And the CyberSource result should be "GREEN"
    And the case should have proceeded automatically and not be parked in Fraud Queue
    And the system should have appended the booking record automatically for identified and authenticated user
    And Trip Tracer poll should NOT be required
    And the agent should have used pull case from My Activities
    And the case status should have transitioned from "Assigned" to "In Progress"
    And a case acknowledgement notification should have been sent
    And an eligible notification email should have been sent via Adobe
    And the Agent Notes section should be accessible
    And the Audit Log should record all actions with timestamps and before/after values
    And Customer Communications should show the notification email chronologically
    And the chatbot transcript should be accessible and linked to the case
    And the Attachments tab should be empty
    And the Final Status should be "Resolved"
    And the case should be in read-only mode with no editable Decision Assist fields
    And the agent should not be able to access Case Search as it is for leads and management only


Feature: Payment Validation � TC013 Catherine Bouchard

  Scenario: Validate Payment for TC013 Catherine Bouchard
    Given the CyberSource fraud screening result is "GREEN" so the normal payment flow should proceed
    And the customer's country of residence is "Canada"
    Then the currency should be set to "CAD"
    And the payment method should be "Interac e-Transfer"
    And the customer has no Aeroplan linked so only Cash should be offered
    And a compensation record should be created
    And the record should be picked up by the daily evening batch file
    And the record should be dispatched to Unifier
    And in UAT the batch file should be triggered manually
    And Unifier should send an acknowledgement back
    And the end-of-day report should be received from Interac
    And the status should be "Pending" transitioning to "Cached" or "Rejected" or "Expired"
    And if the payment is unclaimed after 35 days the status should be set to "Expired"
    And the Claims Dashboard Compensation tab should show the correct amount
    And the currency should be displayed
    And the payment method should be displayed
    And the status should be updated


Feature: Claims Dashboard Validation � TC014 Fran�ois Pelletier (CyberSource YELLOW)

  Scenario: Validate Claims Dashboard for TC014 Fran�ois Pelletier (CyberSource YELLOW)
    Given the case has been created for claimant "Fran�ois Pelletier" with PNR "TC014"
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
    And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
    And the Case Status should be "In Review" or "Done"
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be correct
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel should NOT be greyed out
    And the Claimant Name should be "Fran�ois Pelletier"
    And the Claimant Type should be "Adult"
    And the Authentication should be "Pass"
    And the PNR should be "TC014"
    And the PNR Creation Date should be populated
    And the Journey ID should be populated
    And the Booking Source should be populated
    And the Booking Office ID should be populated
    And the Regime should be "APPR"
    And the Full Name should be "Fran�ois Pelletier"
    And the Tags should include "Claimant" and "Adult"
    And the Email should be "f***@gmail.com"
    And the Phone should be "+1***456"
    And the Address should be populated
    And the Aeroplan should be "Not linked"
    And the Profile ID should be populated
    And the Tier Status should be populated
    And the Journey should show "Bound 1: YUL ? YYZ" with claim filed for this flight
    And the Ancillary Fee section should be present
    And the expected ancillary fees should be none
    And the Eligibility and Compensation section should be present and populated for this automated FD case
    And the Decision Assist Panel should auto-appear for FD topic
    And DDS should have run automatically with no agent action needed
    And the eligibility decision should be pre-populated
    And the Duplicate Check should have run automatically using baseline data "Fran�ois Pelletier + TC014 + YUL?YYZ + FD"
    And the result should be "No duplicate found"
    And no Duplicate Warning Banner should be displayed
    And the Related Cases tab should show no related cases
    And the CyberSource result should be "YELLOW" indicating suspicious activity detected
    And the case should move to the Fraud Queue in Claims Dashboard
    And the CyberSource team should review in their tool and not in Claims Dashboard
    And the case should be parked with no agent able to action it until CyberSource responds
    And the Fraud Queue should only be visible to fraud team and management roles
    And the customer flow should have continued as YELLOW does not block the customer
    And if CyberSource approves the case from YELLOW status the case should resume the automated flow
    And if CyberSource rejects the case after YELLOW review a rejection notification should be sent and the case should be closed with a specific closure status
    And the system should have appended the booking record automatically for identified and authenticated user
    And Trip Tracer poll should NOT be required
    And the agent should have used pull case from My Activities
    And the case status should have transitioned from "Assigned" to "In Progress" to "Parked" awaiting CyberSource review
    And a case acknowledgement notification should have been sent
    And an eligible notification email should have been sent via Adobe as YELLOW does not block customer messaging
    And the Agent Notes section should be accessible
    And the Audit Log should record all actions with timestamps and before/after values including the CyberSource YELLOW flag
    And Customer Communications should show the notification email chronologically
    And the chatbot transcript should be accessible and linked to the case
    And the Attachments tab should be empty
    And the Case Status should be "Parked" awaiting CyberSource fraud team review
    And the case should NOT be in read-only mode yet as it is pending fraud review outcome
    And the agent should not be able to access Case Search as it is for leads and management only


Feature: Payment Validation � TC014 Fran�ois Pelletier (CyberSource YELLOW)

  Scenario: Validate Payment for TC014 Fran�ois Pelletier (CyberSource YELLOW)
    Given the CyberSource fraud screening result is "YELLOW"
    Then the customer flow should continue normally
    But the compensation should be HELD pending manual review by the CyberSource team


Feature: Claims Dashboard Validation � TC015 Alain Moreau (CyberSource RED)

  Scenario: Validate Claims Dashboard for TC015 Alain Moreau (CyberSource RED)
    Given the case has been created for claimant "Alain Moreau" with PNR "TC015"
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
    And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
    And the Case Status should be "Pending Fraud Manual Review"
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be "Fraud Investigation Team"
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel may be restricted due to fraud flag
    And the Claimant Name should be "Alain Moreau"
    And the Claimant Type should be "Adult"
    And the Authentication should be "Pass"
    And the PNR should be "TC015"
    And the PNR Creation Date should be populated
    And the Journey ID should be populated
    And the Booking Source should be populated
    And the Booking Office ID should be populated
    And the Regime should be "APPR"
    And the Full Name should be "Alain Moreau"
    And the Tags should include "Claimant" and "Adult"
    And the Email should be "a***@outlook.com"
    And the Phone should be "+1***567"
    And the Address should be populated
    And the Aeroplan should be "Not linked"
    And the Profile ID should be populated
    And the Tier Status should be populated
    And the Journey should show "Bound 1: YUL ? YYZ" with claim filed for this flight
    And the Ancillary Fee section should be present
    And the expected ancillary fees should be none
    And the Eligibility and Compensation section should be present and DDS should have determined eligible but payment should be blocked by CyberSource RED
    And the Decision Assist Panel should auto-appear for FD topic
    And DDS should have run automatically with no agent action needed
    And the eligibility decision should be pre-populated as eligible per DDS but blocked by fraud
    And the Duplicate Check should have run automatically using baseline data "Alain Moreau + TC015 + YUL?YYZ + FD"
    And the result should be "No duplicate found"
    And no Duplicate Warning Banner should be displayed
    And the Related Cases tab should show no related cases
    And the CyberSource result should be "RED" indicating fraud detected and high risk
    And the customer should have been told the case cannot be processed through the automated system and redirected to Customer Relations
    And the automated payment flow should have been BLOCKED
    And no payment should have been initiated with no country of residence, no payment method, and no IDV
    And the case should be flagged as "FRAUD DETECTED"
    And the case should be routed to the fraud investigation team
    And a dispute option should be offered as required by privacy law
    And if disputed the case should go to the CyberSource queue for review
    And if CyberSource rejects the case after review a rejection notification should be sent and the case should be closed with a specific closure status
    And the system should have appended the booking record automatically for identified and authenticated user
    And Trip Tracer poll should NOT be required
    And the case should be routed directly to the fraud investigation team and not the regular agent queue
    And a generic notification email should have been sent to "a***@outlook.com"
    And the email should contain the Case Reference and a generic message about contacting Customer Relations
    And the email should NOT mention fraud detection as a security measure
    And the Agent Notes section should be accessible
    And the Audit Log should record all actions with timestamps including the CyberSource RED flag and BLOCK action
    And Customer Communications should show the generic notification email
    And the chatbot transcript should be accessible and linked to the case
    And the Attachments tab should be empty
    And the Case Status should be "Blocked � Fraud Review"
    And the case should NOT be resolved as it is pending fraud investigation outcome
    And the agent should not be able to access Case Search as it is for leads and management only
    And the Fraud Queue should only be visible to fraud team and management roles


Feature: Payment Validation � TC015 Alain Moreau (CyberSource RED)

  Scenario: Validate Payment for TC015 Alain Moreau (CyberSource RED)
    Given the CyberSource fraud screening result is "RED"
    Then no payment flow should be triggered
    And the customer should be offered a dispute option as required by privacy law
    And the Claims Dashboard should show CyberSource result as "RED"
    And the case should be auto-rejected
    And a dispute record should exist if the customer disputed


Feature: Claims Dashboard Validation � TC016 Diane Lefebvre (CyberSource GREEN + RDS Flag)

  Scenario: Validate Claims Dashboard for TC016 Diane Lefebvre (CyberSource GREEN + RDS Flag)
    Given the case has been created for claimant "Diane Lefebvre" with PNR "TC016"
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
    And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
    And the Case Status should be "In Review" or "Done"
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be correct
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel should NOT be greyed out
    And the Claimant Name should be "Diane Lefebvre"
    And the Claimant Type should be "Adult"
    And the Authentication should be "Pass"
    And the PNR should be "TC016"
    And the PNR Creation Date should be populated
    And the Journey ID should be populated
    And the Booking Source should be populated
    And the Booking Office ID should be populated
    And the Regime should be "APPR"
    And the Full Name should be "Diane Lefebvre"
    And the Tags should include "Claimant" and "Adult"
    And the Email should be "d***@gmail.com"
    And the Phone should be "+1***678"
    And the Address should be populated
    And the Aeroplan should be "Not linked"
    And the Profile ID should be populated
    And the Tier Status should be populated
    And the Journey should show "Bound 1: YUL ? YYZ" with claim filed for this flight
    And the Ancillary Fee section should be present
    And the expected ancillary fees should be none
    And the Eligibil