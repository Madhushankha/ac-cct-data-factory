Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight from Montreal to Toronto was changed by the airline and I arrived much later than planned. Can I get compensation?"
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
And the user provides "Laurent Tremblay"
Then the chatbot responds:
"Thanks, Laurent! And, what is your booking reference number?"
And the user provides "PNR: TCINVOL01"
Then the chatbot searches Trip Tracer for PNR: TCINVOL01
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer
AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
� Email: l***@gmail.com
� Phone: +1***234
And the user selects "Email: l***@gmail.com"
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
� Laurent Tremblay (Adult)
Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED
JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
� Flight: AC 421
� Route: Montreal (YUL) ? Toronto (YYZ)
� Date: June 10, 2026
� Arrival Delay: 4.5 hours
Is this the journey you'd like to check?"
And the user confirms "Yes"
SEGMENT CHECK:
Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18
DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for this passenger + journey combination
72-HOUR CHECK:
Then the chatbot checks: Hours since last leg arrival ? >72 hours ? PROCEED
REGIME DETERMINATION:
Then the system determines: Origin = YUL (Canada) ? APPR
TRIAGE & DDS EVALUATION � INVOL CHANGE DETECTED:
Then the DDS evaluation is done in backend
And DDS checks booking change history:
? Change 1 (D-2): REACC auto-rebook (identifier: MUC1A06AC / YMQAC05IN in PNR history)
? Classification: INVOL (REACC = system-initiated auto-accommodation after disruption)
? REACC changed arrival from 10:00 ? 14:30
? Promise update: NO � INVOL does NOT update promise
? Promise remains at: 10:00 (14-day mark)
? Actual arrival: 14:30
? Delay from promise: 14:30 - 10:00 = 4.5 hours
? APPR: Delay 3�6h, Controllable (Code 42) ? ELIGIBLE � $400 CAD (Tier 1)
TRIP TRACER UI VALIDATION:
Then the tester opens Trip Tracer UI for PNR: TCINVOL01
? Promised Itinerary - Flight: AC 421, Route: YUL ? YYZ, Scheduled Arrival: 10:00 (14-day mark � NOT updated by REACC)
? Current Itinerary - Flight: AC 421, Route: YUL ? YYZ, Status: ARRIVED LATE, Actual: 14:30, Delay: +4H 30M
? Change History:
Change 1: REACC (MUC1A06AC / YMQAC05IN) at D-2 � INVOL � arrival 10:00 ? 14:30
? Promise = 10:00 (14-day mark � REACC did NOT update it)
? Delay from promise = 4.5 hours
? Regime: APPR
? APPR: Delay 3�6h, Controllable ? ELIGIBLE
? MSL FLIGHT: AC 421 � YUL ? YYZ � 42
? CONTROLLABLE (Code 42)
Flight Compensation:
? MR LAURENT TREMBLAY | ELIGIBLE | APPR_3_TO_6_HOURS | CAD $400
FRAUD SCREENING � CYBERSOURCE (GLOB-05):
Then the chatbot sends case details to CyberSource for fraud screening
And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected)
And the customer is cleared to proceed to payment
ELIGIBLE RESULT (FD-05a):
Then the chatbot displays:
"I've checked your flight details, and it looks like flight AC 421 from Montreal (YUL) to Toronto (YYZ) was delayed by about 4 hours and 30 minutes. Based on the Canadian Air Passenger Protection Regulations (APPR), you may be eligible for compensation of $400 CAD for this delay. I'll guide you through the next steps so we can get your claim submitted and processed as quickly as possible."
CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW:
Then the chatbot asks:
"Thank you for confirming. In which country will your reimbursement be deposited?"
And the user selects "Canada"
Then the system determines: Country = Canada ? Currency = CAD
CASH vs AC WALLET CHECK (FD-06b):
Then the chatbot checks: Does customer have Aeroplan number on booking? ? No
Then the chatbot checks if the claim is for multiple pax ? No
Then the chatbot responds: "You are entitled to receive a $400 CAD compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed?"
And an alert information is displayed: "Please note that payments will be deposited in your local currency."
And user provides "Yes"
Then system checks which payment method is mapped based on country of residence ? Interac e-Transfer (Canada)
PAYMENT METHOD � INTERAC E-TRANSFER (FD-07):
Then the chatbot responds:
"Your payment will be made through Interac e-Transfer. Before we move forward, please provide the email address where you'd like to receive the transfer."
And the user provides "laurent.tremblay@gmail.com"
Then the chatbot confirms: "Thank you. Your Interac e-Transfer details have been recorded."
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
CLAIM AMOUNT CONFIRMATION FLOW:
Then the chatbot responds: "Please review your compensation details:
Deposit Amount: $400 CAD
Payment Method: Interac e-Transfer
After submission, you will receive a confirmation email summarizing your eligibility, claim details and next steps.
Would you like me to submit your claim?"
And an alert information is displayed: "Please note that the payment details cannot be changed after submission."
When the user provides: "Yes"
CASE CREATION (GLOB-09):
Then the chatbot responds: "Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your claim details, and a second email that will include the secure link where you'll provide your information."
And an alert information is displayed: "Claim submission successful!"
And the system appends the booking record to the case automatically
NOTIFICATION (Adobe):
Then the system triggers notification via Adobe:
And an eligible notification email is sent to l***@gmail.com
And the email contains: Case Reference, compensation amount ($400 CAD), regulation (APPR), flight details (AC 421, YUL?YYZ, 4.5hr delay), next steps, tracking link
END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given the case has been created for claimant "Laurent Tremblay" with PNR "TCINVOL01"
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
    And the Case Status should be "In Review" or "Done"
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be correct
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel should NOT be greyed out
    And the Claimant Name should be "Laurent Tremblay"
    And the Claimant Type should be "Adult"
    And the Authentication should be "Pass"
    And the PNR should be "TCINVOL01"
    And the Regime should be "APPR"
    And the Full Name should be "Laurent Tremblay"
    And the Tags should include "Claimant" and "Adult"
    And the Journey should show "Bound 1: YUL ? YYZ"
    And the Ancillary Fee section should be present
    And the expected ancillary fees should be none
    And the Eligibility should be "ELIGIBLE" under APPR with compensation "$400 CAD" Tier 1 3 to less than 6hrs controllable
    And the Change History should show REACC MUC1A06AC or YMQAC05IN as INVOL
    And the Promise should be 10:00 at 14-day mark NOT updated by REACC
    And the Actual should be 14:30
    And the Delay should be 4.5hrs
    And the Decision Assist Panel should auto-appear for FD topic
    And DDS should have run automatically
    And INVOL should have been detected via REACC tool MUC1A06AC or YMQAC05IN
    And the promise should NOT have been updated and should stay at 14-day mark
    And the result should be ELIGIBLE at $400 CAD
    And the Duplicate Check should have run automatically using baseline data "Laurent Tremblay + TCINVOL01 + YUL?YYZ + FD"
    And the result should be "No duplicate found"
    And no Duplicate Warning Banner should be displayed
    And the Related Cases tab should show no related cases
    And the CyberSource result should be "GREEN"
    And the system should have appended the booking record automatically
    And an eligible notification email should have been sent via Adobe containing Case Reference and compensation $400 CAD and regulation APPR and flight details AC 421 YUL to YYZ 4.5hr delay and next steps
    And the Agent Notes section should be accessible
    And the Audit Log should record REACC INVOL detected MUC1A06AC or YMQAC05IN and promise unchanged at 10:00 and delay 4.5hrs and eligible $400
    And Customer Communications should show the eligible notification email chronologically
    And the chatbot transcript should be accessible and linked to the case
    And the Attachments tab should be empty
    And the Final Status should be "Resolved"
    And the case should be in read-only mode
    And the agent should not be able to access Case Search as it is for leads and management only

PAYMENT VALIDATION
    Given the customer's country of residence is "Canada"
    Then the currency should be set to "CAD"
    And the payment method should be "Interac e-Transfer"
    And the customer has no Aeroplan linked so only Cash should be offered and AC Wallet should NOT be offered
    And the compensation amount should be "$400 CAD" APPR Tier 1 3 to less than 6hrs controllable
    And the Interac e-Transfer email should be collected as one-time non-editable after submission
    And IDV at Payment should be triggered via Persona and the customer should complete IDV and Persona should return IDV PASS
    And the claim amount confirmation should show $400 CAD via Interac e-Transfer and the customer should confirm and the claim should be submitted
    And a compensation record should be created in the backend with GL account and cost center
    And in UAT the batch file should be triggered manually in coordination with the Unifier and SAP team
    And Cash should be dispatched to Unifier and Unifier should process Interac e-Transfer for $400 CAD
    And Unifier should send an acknowledgement back and the end-of-day report should be received
    And the end-of-day report from Interac should show status "Pending" transitioning to "Cached" or "Rejected" or "Expired"
    And if unclaimed after 35 days the status should be Expired
    And if payment fails due to invalid email or Interac not registered a failure notification should be sent to the case and the agent should be flagged
    And the Claims Dashboard Compensation tab should show payout details "$400 CAD" with payment method "Cash" via "Interac e-Transfer" and status updated via talkback

Expected Results:
Tool: REACC (MUC1A06AC / YMQAC05IN); Classification: INVOL; Promise: 10:00 (14-day mark � NOT updated); Actual: 14:30; Delay: 4.5hrs; APPR Tier 1; ELIGIBLE $400 CAD |