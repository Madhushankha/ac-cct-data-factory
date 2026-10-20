Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight just landed 2 hours ago and it was delayed 4 hours. I'd like to file a compensation claim right away"
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
And the user provides "Marc-Andr� Lavoie"
Then the chatbot responds:
"Thanks, Marc-Andr�! And, what is your booking reference number?"
And the user provides "PNR: TC060"
Then the chatbot searches Trip Tracer for PNR: TC060
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer
AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
� Email: m***@gmail.com
� Phone: +1***789
And the user selects "Email: m***@gmail.com"
Then the chatbot responds:
"I've sent a verification code to your email, please enter it within 15 minutes of receiving it."
And the user provides the OTP code "482917"
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
� Marc-Andr� Lavoie (Adult)
Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED
JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
� Flight: AC 504
� Route: Montreal (YUL) ? Toronto (YYZ)
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
And the system calculates: Arrival was June 15, 2026 at 10:00; current time is June 15, 2026 at 12:31 ? 2 hours 31 minutes ? LESS THAN 72 HOURS
Then the system determines: 72-HOUR WINDOW NOT ELAPSED ? CASE PLACED IN SYSTEM PROCESSING QUEUE
PENDING RESULT (72 Hours Not Elapsed):
Then the chatbot displays:
"Thank you for submitting your claim. Your flight AC 504 from Montreal (YUL) to Toronto (YYZ) on June 15, 2026 has been recorded. Please note that claims require a processing period of up to 72 hours after your flight arrival before we can assess your eligibility. Your claim has been placed in our processing queue and will be automatically reviewed once the processing window has passed. You will receive an email notification with the results."
NO DDS EVALUATION (not yet run � 72 hours not elapsed)
NO PAYMENT FLOW (pending)
NO IDV (pending)
NO FRAUD SCREENING (pending)
CASE CREATION (GLOB-09):
Then the chatbot responds: "Your claim has been submitted successfully and is now in our processing queue."
And an alert information is displayed: "Claim submission successful!"
And the system appends the booking record to the case automatically
And the case status is set to: SYSTEM PROCESSING QUEUE
And the system schedules DDS evaluation for 72 hours post-arrival (June 18, 2026 at 10:00)
NOTIFICATION (Adobe):
Then the system triggers notification via Adobe:
And a Pending notification email is sent to m***@gmail.com
And the email contains: Case Reference, flight details, status (pending � 72-hour processing window), expected processing date, tracking link
END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given the case has been created for claimant "Marc-Andr� Lavoie" with PNR "TC060" filed within 72 hours of arrival
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
    And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
    And the Case Status should be "System Processing Queue"
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be correct
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel should NOT yet be populated as DDS has not run
    And the Claimant Name should be "Marc-Andr� Lavoie"
    And the Claimant Type should be "Adult"
    And the Authentication should be "Pass"
    And the PNR should be "TC060"
    And the PNR Creation Date should be populated
    And the Journey ID should be populated
    And the Booking Source should be populated
    And the Booking Office ID should be populated
    And the Regime should be "APPR" pending confirmation after DDS runs
    And the Full Name should be "Marc-Andr� Lavoie"
    And the Tags should include "Claimant" and "Adult"
    And the Email should be "m***@gmail.com"
    And the Phone should be "+1***789"
    And the Address should be populated
    And the Aeroplan should be "Not linked"
    And the Profile ID should be populated
    And the Tier Status should be populated
    And the Journey should show "Bound 1: YUL ? YYZ" with claim filed for this flight
    And the Ancillary Fee section should be present
    And the expected ancillary fees should be none
    And the Eligibility and Compensation section should be present and show "PENDING" as DDS has not yet run and 72 hours have not elapsed
    And the Decision Assist Panel should auto-appear for FD topic
    And DDS should NOT have run yet as the 72-hour window has not elapsed and is scheduled for June 18 2026 at 10:00
    And the eligibility decision should be "PENDING"
    And the Duplicate Check should have run automatically using baseline data "Marc-Andr� Lavoie + TC060 + YUL?YYZ + FD"
    And the result should be "No duplicate found"
    And no Duplicate Warning Banner should be displayed
    And the Related Cases tab should show no related cases
    And CyberSource should NOT have been triggered as DDS has not yet run
    And the system should have appended the booking record automatically for identified and authenticated user
    And Trip Tracer poll should NOT be required
    And the case should be in System Processing Queue and not yet available for agent pull
    And a pending notification email should have been sent to "m***@gmail.com"
    And the email should contain the Case Reference and flight details and status "pending � 72-hour processing window" and expected processing date June 18 2026 and tracking link
    And the Agent Notes section should be accessible
    And the Audit Log should record case creation with timestamps
    And Customer Communications should show the pending notification email
    And the chatbot transcript should be accessible and linked to the case
    And the Attachments tab should be empty
    And the Case Status should be "System Processing Queue" with DDS scheduled for June 18 2026 at 10:00
    And the case should NOT be in read-only mode as it is pending system processing
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
DDS returns FD-APPR-PE-01 (Pending). Trip Tracer: Data may or may not be available yet � within 72hr processing window. Case status: PENDING � waiting for DDS processing. System behavior: Case created with collected customer data; DDS will auto-process when 72hr window expires; No polling needed (unlike ND scenarios) � this is expected timing, not missing data. After 72hrs: DDS processes ? returns definitive code (EL/NE/ND). Claims Dashboard: Status = Pending; Reason = Within 72hr processing window; Auto-assessment scheduled; DDS = FD-APPR-PE-01.