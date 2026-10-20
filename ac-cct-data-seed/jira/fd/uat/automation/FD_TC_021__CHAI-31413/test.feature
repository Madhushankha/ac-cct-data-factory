Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight just landed 4 hours late yesterday, I want to file a compensation claim right away"
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
And the user provides "Mathieu Roy"
Then the chatbot responds:
"Thanks, Mathieu! And, what is your booking reference number?"
And the user provides "PNR: TC017"
Then the chatbot searches Trip Tracer for PNR: TC017
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer

AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
� Email: m***@outlook.com
� Phone: +1***789
And the user selects "Email: m***@outlook.com"
Then the chatbot responds:
"I've sent a verification code to your email, please enter it within 15 minutes of receiving it."
And the user provides the OTP code "619374"
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
"I found 1 passenger on this booking:
� Mathieu Roy (Adult)
Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED

JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
� Flight: AC 429
� Route: Montreal (YUL) ? Toronto (YYZ)
� Date: June 3, 2026
� Arrival Delay: 4 hours
Is this the journey you'd like to check?"
And the user confirms "Yes"

SEGMENT CHECK:
Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18

DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for this passenger + journey combination

72-HOUR CHECK:
Then the chatbot checks: Hours since last leg arrival
And the system calculates: Arrival was June 3, 2026 at 18:00; current date is June 4, 2026 at 14:00 ? 20 hours ? LESS THAN 72 hours ? 72-HOUR WINDOW NOT MET

PENDING RESULT (FD-PE-01):
Then the chatbot displays:
"Thank you for submitting your claim. Your claim has been recorded and will be automatically processed once we have complete flight data. You will receive an email notification with the result. You don't need to come back � we'll handle everything automatically."

CASE CREATION (GLOB-09 � PENDING):
Then the system creates a case in PENDING status:
And the case status = "Pending � Awaiting 72-Hour Window"
And the system sets auto-trigger for DDS evaluation at 72 hours post-arrival (June 6, 2026 18:00)
And the booking record is appended automatically

NOTIFICATION (Adobe):
Then the system triggers notification via Adobe:
And a pending notification email is sent to m***@outlook.com
And the email contains: Case Reference, status (Pending � Awaiting Assessment), expected assessment date (June 6, 2026), flight details, next steps

NO FURTHER PROCESSING AT THIS TIME:
Then the chatbot does NOT proceed to DDS evaluation
And the chatbot does NOT proceed to CyberSource
And the chatbot does NOT proceed to payment
And the chatbot does NOT proceed to IDV

END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

POST-72-HOUR AUTO-PROCESSING (BACKGROUND):
When 72 hours have elapsed since arrival (June 6, 2026 at 18:00)
Then the system automatically triggers DDS evaluation for the pending case
And DDS runs the full assessment (Steps 1-8)
And the system determines eligibility
Then the system sends a "Welcome Back" notification email to m***@outlook.com
And the email contains: Case Reference, eligibility result, compensation amount (if eligible), next steps to complete payment (if eligible)
And the customer can return to the chatbot to complete the payment flow

CLAIMS DASHBOARD VALIDATION
    Given the case has been created for claimant "Mathieu Roy" with PNR "TC017" filed within 72 hours of arrival
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
    And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
    And the Case Status should be "Pending � Awaiting 72-Hour Window"
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be "System Processing Queue" with no agent assignment
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel may not be fully populated as DDS has not run yet
    And the Claimant Name should be "Mathieu Roy"
    And the Claimant Type should be "Adult"
    And the Authentication should be "Pass"
    And the PNR should be "TC017"
    And the PNR Creation Date should be populated
    And the Journey ID should be populated
    And the Booking Source should be populated
    And the Booking Office ID should be populated
    And the Regime should be "APPR"
    And the Full Name should be "Mathieu Roy"
    And the Tags should include "Claimant" and "Adult"
    And the Email should be "m***@outlook.com"
    And the Phone should be "+1***789"
    And the Address should be populated
    And the Aeroplan should be "Not linked"
    And the Profile ID should be populated
    And the Tier Status should be populated
    And the Journey should show "Bound 1: YUL ? YYZ" with claim filed for this flight
    And the Ancillary Fee section should be present
    And the expected ancillary fees should be none
    And the Eligibility and Compensation section should be present but NOT yet populated as DDS has not run and the 72-hour window has not been met
    And the Decision Assist Panel should auto-appear for FD topic
    And DDS should NOT have run yet as the 72-hour window has not elapsed
    And the eligibility decision should NOT be pre-populated
    And the 72-hour window should NOT have been met as the claim was filed 20 hours after arrival
    And the case should have entered the System Processing Queue with no agent assignment
    And the case should NOT be routed to an agent
    And the system should have set an auto-trigger for DDS evaluation at 72 hours post-arrival
    And if DDS has no answer after 14 days the case should auto-route to the agent queue
    And the Duplicate Check should have run automatically using baseline data "Mathieu Roy + TC017 + YUL?YYZ + FD"
    And the result should be "No duplicate found"
    And no Duplicate Warning Banner should be displayed
    And the Related Cases tab should show no related cases
    And CyberSource should NOT have been triggered as it only runs after DDS determines eligibility and DDS has not run yet
    And the system should have appended the booking record automatically for identified and authenticated user
    And Trip Tracer poll should NOT be required
    And the case should NOT be in any agent's queue and should be in the System Processing Queue
    And no agent pull case action should be expected at this time
    And a pending notification email should have been sent to "m***@outlook.com"
    And the email should contain the Case Reference and status "Pending � Awaiting Assessment" and expected assessment date and flight details and next steps
    And the Agent Notes section should be accessible
    And the Audit Log should record case creation and pending status with timestamps
    And Customer Communications should show the pending notification email
    And the chatbot transcript should be accessible and linked to the case
    And the Attachments tab should be empty
    And the Case Status should be "Pending � Awaiting 72-Hour Window" in the System Processing Queue
    And the case should NOT be in read-only mode as it is still pending processing
    And after 72 hours elapse and DDS runs the case should transition to eligible or not eligible and a Welcome Back email should be sent
    And the agent should not be able to access Case Search as it is for leads and management only

PAYMENT VALIDATION
    Given the case was filed within 72 hours of arrival and was placed in the System Processing Queue
    And 72 hours have elapsed since arrival so DDS should run and return an eligible result
    Then a Welcome Back email should be sent to the customer with a deep link
    And the customer clicks the deep link and returns to the flow
    And the payment flow should trigger from this point
    And the customer's country of residence is "Canada"
    And the currency should be set to "CAD"
    And the payment method should be "Interac e-Transfer"
    And a compensation record should be created
    And the record should be picked up by the daily evening batch file
    And the record should be dispatched to Unifier
    And Unifier should send an acknowledgement back
    And the end-of-day report should be received from Interac
    And the status should be "Pending" transitioning to "Cached" or "Rejected" or "Expired"
    And if the payment is unclaimed after 35 days the status should be set to "Expired"
    And the Claims Dashboard Compensation tab should show payout details updated via talkback

Expected Results:
DDS returns PENDING initially. Case created: Status = Pending; Reason = Filed before 72hrs; DDS data unavailable. "Polling: System polls DDS daily (DDS operates post-journey, 72 hours after final arrival). Trip Tracer stores data; DDS runs eligibility.". At D+4: Data arrives ? DDS processes ? FD-APPR-EL-01. Notification: Deep link email sent to customer. Customer returns: Completes claim ? $400 CAD. Claims Dashboard: Shows polling history; Data arrival timestamp; Welcome Back flow = TRUE.