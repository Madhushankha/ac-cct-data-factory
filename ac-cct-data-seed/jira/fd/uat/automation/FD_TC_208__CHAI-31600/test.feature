Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01): "Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight was cancelled 5 days before I was supposed to travel and I decided not to rebook. I no longer want to travel. Can I get compensation?"
When the chatbot identifies flight disruption intent
Then the chatbot checks: Is this a third-party submission? ? NO
Then the chatbot responds: "No problem, I can help you create a claim for your cancelled flight and see if you are eligible for compensation."

LEGAL DISCLAIMER:
Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need your booking reference, the name associated to the booking and any receipts you'd like to be reimbursed for. If your claim is eligible, you may also need to provide your address, contact information and where you'd like the funds deposited. Would you like to get started?"

IDENTIFICATION (GenUC-01):
Then the chatbot responds: "I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you."
And the chatbot responds: "Please provide your full name exactly as it appears on your ticket, including any middle names if applicable."
And the user provides "Mathieu Pelletier"
Then the chatbot responds: "Thanks, Mathieu! And, what is your booking reference number?"
And the user provides "PNR: TC182"
Then the chatbot searches Trip Tracer for PNR: TC182
And Trip Tracer returns: PNR FOUND (Auth Flow 1)

AUTHENTICATION (GenUC-05):
Then the chatbot responds: "To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
� Email: m***@gmail.com
� Phone: +1***456
And the user selects "Email: m***@gmail.com"
Then the chatbot responds: "I've sent a verification code to your email, please enter it within 15 minutes of receiving it."
And the user provides the OTP code "738291"
Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5)
Then the chatbot responds: "Your verification was successful. Let's proceed to the next step."

GROUP BOOKING CHECK:
Then the system checks Trip Tracer for group booking identifier
And group booking identifier = NOT PRESENT
And system proceeds to passenger selection

PASSENGER SELECTION (GenUC-06):
Then the chatbot asks: "How many people are on your claim?"
And the chatbot displays passengers from PNR: "I found 1 passenger on this booking:
� Mathieu Pelletier (Adult) Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED

JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays: "I found the following journey:
� Flight: AC 430
� Route: Montreal (YUL) ? Toronto (YYZ)
� Date: June 20, 2026
� Status: CANCELLED Is this the journey you'd like to check?"
And the user confirms "Yes"

NO TRAVEL CONFIRMATION:
Then the chatbot asks: "I can see this flight was cancelled. Did you travel on an alternative flight or did you decide not to travel?"
And the user responds: "I decided not to travel"
Then the chatbot confirms: "Understood. I'll process your claim based on the cancelled flight without rebooking."

SEGMENT CHECK:
Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18

DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for this passenger + journey combination

72-HOUR CHECK:
Then the chatbot checks: Hours since cancellation notification
And the system calculates: Cancellation notified June 15, 2026; current date June 25, 2026 ? >72 hours ? PROCEED

CLAIM TIME LIMIT CHECK:
Then the chatbot checks: Filing deadline for APPR = 366 days from disruption
And the system calculates: Disruption June 20, 2026 (original travel date); filing June 25, 2026 ? 5 days ? within 366 days ? PROCEED

TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS Evaluates and sends to Trip Tracer UI:

TRIP TRACER UI VALIDATION
Then the tester opens Trip Tracer UI for PNR: TC182
? Promised Itinerary - Flight: AC 430, Route: YUL ? YYZ, Scheduled Arrival: 10:00 (14-day mark)
? Current Itinerary - Flight: AC 430, Route: YUL ? YYZ, Status: CANCELLED, No Actual Arrival
? History - Change 1 (Day -5): INVOL � AC cancels flight
? No Travel: Customer elected not to rebook
? Regime: APPR (1 regime)
? MSL FLIGHT: AC 430 � YUL ? YYZ � CREW
? "Flight cancelled � crew scheduling"
? Cancellation: D-5 � CONTROLLABLE (CREW)
? Fallback: FALSE � Sister City: FALSE
Flight Compensation:
? MR MATHIEU PELLETIER

CLAIMS DASHBOARD VALIDATION
    Given the case has been created for claimant "Mathieu Pelletier" with PNR "TC182"
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Cancellation"
    And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
    And the Case Status should be "In Review" or "Done"
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be correct
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel should NOT be greyed out
    And the Claimant Name should be "Mathieu Pelletier"
    And the Claimant Type should be "Adult"
    And the Authentication should be "Pass"
    And the PNR should be "TC182"
    And the PNR Creation Date should be populated
    And the Journey ID should be populated
    And the Booking Source should be populated
    And the Booking Office ID should be populated
    And the Regime should be "APPR"
    And the No Travel Flag should be TRUE
    And the Full Name should be "Mathieu Pelletier"
    And the Tags should include "Claimant" and "Adult"
    And the Email should be "m***@gmail.com"
    And the Phone should be "+1***456"
    And the Address should be populated
    And the Aeroplan should be "Not linked"
    And the Profile ID should be populated
    And the Tier Status should be populated
    And the Journey should show "Bound 1: YUL ? YYZ" as CANCELLED with No Travel
    And the Ancillary Fee section should be present
    And the expected ancillary fees should be none
    And the Eligibility and Compensation section should be present and populated for this automated FD case
    And the Decision Assist Panel should auto-appear for FD topic
    And DDS should have run automatically with no agent action needed
    And the eligibility decision should be pre-populated
    And the Duplicate Check should have run automatically using baseline data "Mathieu Pelletier + TC182 + YUL?YYZ + FD"
    And the result should be "No duplicate found"
    And no Duplicate Warning Banner should be displayed
    And the Related Cases tab should show no related cases
    And the CyberSource result should be "GREEN"
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

PAYMENT VALIDATION
    Given the customer did not travel and is not eligible for flight disruption compensation under APPR
    Then no FD compensation payment should be processed for this test case
    And the chatbot must NOT trigger CyberSource fraud screening
    And the chatbot must NOT present Cash vs AC Wallet options
    And the chatbot must NOT initiate Interac or wire transfer or any other payment method
    And instead the chatbot should route the customer to the Refund flow for the unused ticket
    And no compensation record should be created in the FD payment pipeline
    And no daily batch file entry should be generated for Unifier
    And no Unifier acknowledgement should be expected
    And no end-of-day report entry should exist for this case in the FD compensation report
    And the Claims Dashboard Compensation tab should show "N/A � No Travel" or equivalent with no payout amount and no currency and no payment method and no status
    And if the customer is routed to the Refund flow the refund should be processed through the standard ticket refund pipeline separate from FD compensation
    And the refund request should be created with the correct PNR TC182 and passenger name Mathieu Pelletier and original ticket value
    And the refund method should follow the original form of payment OFP rule with refund going back to the credit card or payment method used at time of booking
    And no 35-day expiry rule should apply as that rule is for FD compensation only not ticket refunds
    And if the system erroneously generates a compensation amount or triggers a payment flow this is a P1 defect as the No Travel path must never produce FD compensation payments

Expected Results:
DDS returns FD-APPR-EL-01. Trip Tracer: Promise = 10:00 (14-day mark); Flight Status = CANCELLED; No Actual Arrival; Cancellation at D-5 (INVOL); Cancellation Code = CREW (Controllable); No Travel = TRUE (customer elected not to rebook); MSL = AC 430 YUL?YYZ. Compensation: $400 CAD. CyberSource: GREEN ? auto-approved.