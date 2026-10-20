Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight was delayed 4 hours, I want compensation"
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
And the user provides "Alain Moreau"
Then the chatbot responds:
"Thanks, Alain! And, what is your booking reference number?"
And the user provides "PNR: TC015"
Then the chatbot searches Trip Tracer for PNR: TC015
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer

AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
� Email: a***@outlook.com
� Phone: +1***567
And the user selects "Email: a***@outlook.com"
Then the chatbot responds:
"I've sent a verification code to your email, please enter it within 15 minutes of receiving it."
And the user provides the OTP code "294718"
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
� Alain Moreau (Adult)
Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED

JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
� Flight: AC 427
� Route: Montreal (YUL) ? Toronto (YYZ)
� Date: May 15, 2026
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
And the system calculates: Arrival was May 15, 2026; current date is June 4, 2026 ? >72 hours ? PROCEED

CLAIM TIME LIMIT CHECK:
Then the chatbot checks: Filing deadline for APPR = 366 days from disruption
And the system calculates: Disruption May 15, 2026; filing June 4, 2026 ? within 366 days ? PROCEED

TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS Evaluates and sends to Trip Tracer UI:

TRIP TRACER UI VALIDATION
Then the tester opens Trip Tracer UI for PNR: TC015
? Promised Itinerary - Flight: AC 427, Route: YUL ? YYZ, Scheduled Arrival: 14:00 (14-day mark)
? Current Itinerary - Flight: AC 427, Route: YUL ? YYZ, Status: ARRIVED LATE, Scheduled Arrival: ~~14:00~~ ? Actual: 18:00, Delay: +4H 00M
? History - No changes recorded
? Regime: APPR (1 regime)
? MSL FLIGHT: AC 427 � YUL ? YYZ � 13
? "Delayed due to oversales"
? Delay: +4H 00M � CONTROLLABLE
Flight Compensation:
  ? MR ALAIN MOREAU | ELIGIBLE | DELAY_3_TO_LT_6_HOURS | CAD 400.00 | [expiry date]

FRAUD SCREENING � CYBERSOURCE (GLOB-05):
Then the chatbot sends case details to CyberSource for fraud screening
And CyberSource evaluates and returns: RED (fraud detected, high risk)
Then the system logs: CyberSource Decision = RED; Risk Score = HIGH; Action = BLOCK AND REDIRECT
And the automated payment flow is BLOCKED
And the case is flagged as FRAUD DETECTED

FRAUD REDIRECT (GLOB-05 RED PATH):
Then the chatbot displays:
"We were unable to verify the information provided using our automated verification system due to discrepancies in the submitted details. Please note that no payment or reimbursement will be issued at this time. If you choose to dispute this automated decision, please let me know and share an explanation, and your case will be sent for further manual review. However, this process may take up to 30 business days. You'll receive an email once a decision is made. Please note that no payment or reimbursement will be issued until a decision is made. For more detail, please consult our Privacy Notice."
When the user says: "There is something wrong."
Then the chatbot responds: "I understand your concern. I can create a case for our team to investigate your case further. Would you like to continue?"


NO PAYMENT FLOW:
Then the chatbot does NOT proceed to country of residence
And the chatbot does NOT proceed to payment method
And the chatbot does NOT proceed to IDV
And NO payment is initiated

CASE CREATION (GLOB-09):
Then the system creates a case with FRAUD flag:
And the case status = "Blocked � Fraud Review"
And the case is routed to the fraud investigation team
And the booking record is appended automatically

NOTIFICATION (Adobe):
Then the system triggers notification via Adobe:
And a generic notification email is sent to a***@outlook.com
And the email contains: Case Reference, generic message about contacting Customer Relations
And the email does NOT mention fraud detection (security measure)

END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
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

PAYMENT VALIDATION
    Given the CyberSource fraud screening result is "RED"
    Then no payment flow should be triggered
    And the customer should be offered a dispute option as required by privacy law
    And the Claims Dashboard should show CyberSource result as "RED"
    And the case should be auto-rejected
    And a dispute record should exist if the customer disputed

Expected Results:
DDS returns FD-APPR-EL-01. Compensation: $400 CAD (calculated but REJECTED). CyberSource: RED ? auto-rejected. Customer offered: Dispute path with document upload option. Claims Dashboard: Fraud = RED; Status = Rejected; Dispute option = Available; Compensation = $400 (not released).