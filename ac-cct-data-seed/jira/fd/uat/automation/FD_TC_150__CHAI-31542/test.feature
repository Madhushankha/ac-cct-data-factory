Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight from Paris to Toronto just landed about 4 hours late due to a crew issue. I'd like to file a compensation claim right away"
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
And the user provides "Philippe Lavoie"
Then the chatbot responds:
"Thanks, Philippe! And, what is your booking reference number?"
And the user provides "PNR: TC116"
Then the chatbot searches Trip Tracer for PNR: TC116
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer
AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
� Email: p***@gmail.com
� Phone: +33***123
And the user selects "Email: p***@gmail.com"
Then the chatbot responds:
"I've sent a verification code to your email, please enter it within 15 minutes of receiving it."
And the user provides the OTP code "518293"
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
� Philippe Lavoie (Adult)
Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED
JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
� Flight: AC 871
� Route: Paris Charles de Gaulle (CDG) ? Toronto (YYZ)
� Date: June 15, 2026
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
And the system calculates: Arrival was June 15, 2026 at ~17:00 UTC; current time is June 15, 2026 at ~10:05 UTC ? approximately 0 hours since arrival ? LESS THAN 72 HOURS
Then the system determines: 72-HOUR WINDOW NOT YET ELAPSED ? CASE PLACED IN PENDING / SYSTEM PROCESSING QUEUE
PENDING STATUS � 72-HOUR HOLD:
Then the chatbot responds:
"Thank you for submitting your claim. Your claim has been received and is currently being processed. Please note that it may take up to 15 days to fully assess your eligibility. You will receive an email with the outcome of your claim once the review is complete."
And an alert information is displayed: "Claim submission successful!"
CASE CREATION (GLOB-09):
Then the system creates the case with status: PENDING (System Processing Queue)
And the system records: Filed within 72 hours of arrival; DDS assessment deferred until 72-hour window elapses
And the system schedules: DDS auto-processing to begin after 72 hours post-arrival (approximately June 18, 2026 at ~17:00 UTC)
And the system appends the booking record to the case automatically
NOTIFICATION (Adobe):
Then the system triggers notification via Adobe:
And a Pending/Received notification email is sent to p***@gmail.com
And the email contains:
Subject: "Your Air Canada claim has been received � [Case Reference]"
Case Reference number
Flight details (AC 871, CDG?YYZ, June 15, 2026, delayed 4h)
Status: "Your claim has been received and is being processed. We will notify you of the outcome within 15 days."
Note: "Please allow time for our systems to finalize flight data before assessment can begin."
Contact information for further questions
END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."
POST-72-HOUR PROCESSING (Background � No Customer Interaction):
When 72 hours have elapsed since arrival (approximately June 18, 2026 at ~17:00 UTC)
Then the system automatically triggers DDS evaluation for PNR: TC116
And DDS retrieves disruption codes from backend
And DDS evaluates eligibility under EU 261 regime
And the case status is updated from "Pending (System Processing Queue)" to the appropriate outcome (Eligible, Not Eligible, or No Determination)
And the customer is notified via email of the final outcome
CLAIMS DASHBOARD VALIDATION (At Filing � Before 72h):
When the agent navigates to Claims Dashboard
And the agent searches for the case by PNR
Then the dashboard displays:
� Case Title: "Travel Disruptions � Delay"
� Status: Pending (System Processing Queue)
� Created: June 15, 2026
� Last updated at: June 15, 2026
� SLA: 15 days
� Team: System Processing
CASE OVERVIEW
� Claimant Name
� Claimant Type
� Authentication
� PNR
� PNR Creation Date
� Journey ID
� Booking Source
� Booking Office ID
� Regime: EU 261 (pending confirmation after DDS runs)
� Pending Reason: Filed within 72 hours of arrival
� Scheduled DDS Run: ~June 18, 2026
PASSENGER INFORMATION
� Full Name
� Tags: Claimant, Adult
� Email
� Phone
� Address
� Tier Status
ITINERARY
� Journey: Bound 1: CDG ? YYZ (DELAYED +4h) (Claim filed for this flight)
ANCILLARY FEE
ELIGIBILITY AND COMPENSATION
� Status: PENDING (awaiting 72-hour window)
� DDS: Not yet run (scheduled after 72h)
CLAIMS DASHBOARD VALIDATION (After 72h � Post-DDS):
When the agent navigates to Claims Dashboard after June 18, 2026
Then the dashboard displays:
� Status: Updated to Eligible / Not Eligible / No Determination (based on DDS result)
� DDS Run: Completed
� Disruption Code: [populated from backend]
� Eligibility: [determined by DDS]

CLAIMS DASHBOARD VALIDATION
    Given the case has been created for claimant "Philippe Lavoie" with PNR "TC116" filed within 72 hours of arrival
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
    And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
    And the Case Status should be "Pending (System Processing Queue)"
    And the Created date should be populated as June 15 2026
    And the Last Updated date should be populated as June 15 2026
    And the SLA should be 15 days
    And the Team assignment should be "System Processing"
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel should be pending as DDS has not yet run
    And the Claimant Name should be "Philippe Lavoie"
    And the Claimant Type should be "Adult"
    And the Authentication should be "Pass"
    And the PNR should be "TC116"
    And the PNR Creation Date should be populated
    And the Journey ID should be populated
    And the Booking Source should be populated
    And the Booking Office ID should be populated
    And the Regime should be "EU 261" pending confirmation after DDS runs
    And the Pending Reason should be "Filed within 72 hours of arrival"
    And the Scheduled DDS Run should be approximately June 18 2026
    And the Full Name should be "Philippe Lavoie"
    And the Tags should include "Claimant" and "Adult"
    And the Email should be "p***@gmail.com"
    And the Phone should be "+33***123"
    And the Address should be populated
    And the Aeroplan should be "Not linked"
    And the Profile ID should be populated
    And the Tier Status should be populated
    And the Journey should show "Bound 1: CDG ? YYZ" delayed plus 4h with claim filed for this flight
    And the Ancillary Fee section should be present
    And the expected ancillary fees should be none
    And the Eligibility and Compensation status should be "PENDING" awaiting 72-hour window
    And DDS should NOT have run yet as it is deferred until 72-hour window elapses approximately June 18 2026
    And no eligibility determination should exist yet
    And the Duplicate Check should have run automatically using baseline data "Philippe Lavoie + TC116 + CDG?YYZ + FD"
    And the result should be "No duplicate found"
    And CyberSource should NOT have been triggered as DDS has not yet determined eligibility
    And the system should have appended the booking record automatically for identified and authenticated user
    And a pending received notification email should have been sent via Adobe to "p***@gmail.com" containing Case Reference and AC 871 CDG to YYZ June 15 delayed 4h and status "received and being processed" and outcome within 15 days and allow time for flight data finalization
    And the Agent Notes section should be accessible
    And the Audit Log should record case creation and pending status
    And Customer Communications should show the pending notification email
    And the chatbot transcript should be accessible and linked to the case
    And the Attachments tab should be empty
    And the Current Status should be "Pending (System Processing Queue)"
    And the case should NOT be in read-only mode as it will be updated after DDS runs post 72h
    And after approximately June 18 2026 the system should automatically trigger DDS evaluation
    And the status should update to Eligible or Not Eligible or No Determination based on DDS result
    And the customer should be notified via email of the final outcome
    And the agent should not be able to access Case Search as it is for leads and management only

PAYMENT VALIDATION
    Given the case is in System Processing Queue pending 72-hour window
    Then no payment flow should be triggered
    And the system should poll DDS for up to 14 days
    And no country of residence should have been asked
    And no compensation record should have been created
    And no batch file should have been dispatched
    And if DDS returns eligible the Welcome Back flow should trigger and then the payment flow should proceed
    And if no answer after 14 days the case should be sent to the agent queue
    And the Claims Dashboard should show case status as "Pending" with no payout section

Expected Results:
DDS returns FD-EU-PE-01 (Pending). Trip Tracer: Data may or may not be available yet � within 72hr processing window. Case status: PENDING � waiting for DDS processing. System behavior: Case created with collected customer data; DDS will auto-process when 72hr window expires; No polling needed � expected timing. After 72hrs: DDS processes ? returns definitive EU code (EL/NE/ND) with distance band and compensation amount. Claims Dashboard: Status = Pending; Reason = Within 72hr processing window; EU 261 regime identified; Auto-assessment scheduled; DDS = FD-EU-PE-01.