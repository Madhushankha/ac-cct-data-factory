Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "I was denied boarding on my flight due to overbooking, I'd like to check if I'm eligible for compensation"
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
And the user provides "Dominique Arsenault"
Then the chatbot responds:
"Thanks, Dominique! And, what is your booking reference number?"
And the user provides "PNR: TC038"
Then the chatbot searches Trip Tracer for PNR: TC038
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer
AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
� Email: d***@gmail.com
� Phone: +1***789
And the user selects "Email: d***@gmail.com"
Then the chatbot responds:
"I've sent a verification code to your email, please enter it within 15 minutes of receiving it."
And the user provides the OTP code "739281"
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
� Dominique Arsenault (Adult)
Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED
JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
� Flight: AC 458
� Route: Montreal (YUL) ? Toronto (YYZ)
� Date: May 27, 2026
� Status: DEPARTED (passenger not on board � Denied Boarding)
Is this the journey you'd like to check?"
And the user confirms "Yes"
SEGMENT CHECK:
Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18
TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS checks: Disruption type? ? DENIED BOARDING
And DDS determines: DENIED BOARDING ? SEPARATE PROCESS (not handled in flight disruption compensation flow)
And DDS sends to Trip Tracer UI:
TRIP TRACER UI VALIDATION
Then the tester opens Trip Tracer UI for PNR: TC038
? Promised Itinerary:
  - Flight: AC 330
  - Route: YUL ? YYZ
  - Scheduled Departure: 10:00
  - Scheduled Arrival: 12:00

? Current Itinerary:
  - Flight: AC 330
  - Route: YUL ? YYZ
  - Status: DEPARTED / ARRIVED (flight operated normally)
  - Actual Departure: 10:05
  - Actual Arrival: 12:02
  - Passenger Status: NOT BOARDED � DENIED BOARDING

? Denied Boarding Event:
  - changeIdentifier: DENIED_BOARDING
  - change_type: INVOLUNTARY
  - Denial Reason: DENIED_BOARDING_OVERSALES (Overbooking)
  - impacted_passenger_id: St�phane Boucher
  - impacted_segment_id: AC 330 YUL?YYZ

? Regime: APPR (1 regime)
? DDS Gate 6: Denied Boarding = TRUE ? NOT ELIGIBLE for Flight Disruption compensation
? Separate APPR DB compensation may apply via Customer Relations

Flight Compensation:
? MR ST�PHANE BOUCHER | NOT ELIGIBLE | DENIED_BOARDING | CAD 0.00 (FD channel)
FRAUD SCREENING � NOT TRIGGERED:
Then the chatbot notes: CyberSource is ONLY called for ELIGIBLE cases
And this case is NOT ELIGIBLE ? CyberSource NOT invoked
NOT ELIGIBLE RESULT (FD-05b):
Then the chatbot displays:
"I've reviewed the details of your flight. I understand you were denied boarding on flight AC 458 from Montreal (YUL) to Toronto (YYZ) on May 27, 2026. However, denied boarding claims are handled through a separate process and are not part of the flight disruption compensation flow. Please contact Air Canada Customer Relations directly or visit aircanada.com for assistance with your denied boarding claim. We sincerely apologize for the inconvenience and appreciate your understanding."
NO PAYMENT FLOW (skipped entirely for not eligible)
NO IDV (not required for not eligible)
CASE CREATION (GLOB-09):
Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your claim details."
And an alert information is displayed: "Claim submission successful!"
And the system appends the booking record to the case automatically
NOTIFICATION (Adobe):
Then the system triggers notification via Adobe:
And a Not Eligible notification email is sent to d***@gmail.com
And the email contains: Case Reference, flight details, not eligible reason (denied boarding � separate process), regulation reference (APPR), contact information for denied boarding claims
END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given the case has been created for claimant "Dominique Arsenault" with PNR "TC038"
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
    And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
    And the Case Status should be "Closed � Not Eligible"
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be correct
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel should NOT be greyed out
    And the Claimant Name should be "Dominique Arsenault"
    And the Claimant Type should be "Adult"
    And the Authentication should be "Pass"
    And the PNR should be "TC038"
    And the PNR Creation Date should be populated
    And the Journey ID should be populated
    And the Booking Source should be populated
    And the Booking Office ID should be populated
    And the Regime should be "APPR"
    And the Full Name should be "Dominique Arsenault"
    And the Tags should include "Claimant" and "Adult"
    And the Email should be "d***@gmail.com"
    And the Phone should be "+1***789"
    And the Address should be populated
    And the Aeroplan should be "Not linked"
    And the Profile ID should be populated
    And the Tier Status should be populated
    And the Journey should show "Bound 1: YUL ? YYZ" with claim filed for this flight
    And the Ancillary Fee section should be present
    And the expected ancillary fees should be none
    And the Eligibility and Compensation section should be present and show "NOT ELIGIBLE" with reason "Denied Boarding � separate process"
    And the Decision Assist Panel should auto-appear for FD topic
    And DDS should have run automatically
    And the eligibility decision should be pre-populated as "NOT ELIGIBLE" due to denied boarding not handled in FD compensation flow
    And the Duplicate Check should have run automatically using baseline data "Dominique Arsenault + TC038 + YUL?YYZ + FD"
    And the result should be "No duplicate found"
    And no Duplicate Warning Banner should be displayed
    And the Related Cases tab should show no related cases
    And CyberSource should NOT have been triggered as it only runs for eligible cases
    And the system should have appended the booking record automatically for identified and authenticated user
    And Trip Tracer poll should NOT be required
    And the agent should have used pull case from My Activities
    And the case status should have transitioned from "Assigned" to "In Progress"
    And a case acknowledgement notification should have been sent
    And a not eligible notification email should have been sent via Adobe
    And the Agent Notes section should be accessible
    And the Audit Log should record all actions with timestamps and before/after values
    And Customer Communications should show the not eligible notification email chronologically
    And the chatbot transcript should be accessible and linked to the case
    And the Attachments tab should be empty
    And the Final Status should be "Closed � Not Eligible"
    And the case should be in read-only mode with no editable Decision Assist fields
    And the agent should not be able to access Case Search as it is for leads and management only

PAYMENT VALIDATION
    Given the eligibility result is "NOT ELIGIBLE" due to Denied Boarding
    Then no payment flow should be triggered
    And no country of residence should have been asked
    And no compensation record should have been created
    And no batch file should have been dispatched
    And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section

Expected Results:
DDS: FD-APPR-NE-06. AC 330 YUL?YYZ operated normally (dep 10:05, arr 12:02). Passenger NOT BOARDED. changeIdentifier = DENIED_BOARDING, INVOLUNTARY, DENIED_BOARDING_OVERSALES. Gate 1: Not employee/infant ? PROCEED. Gate 2: Promised dep 10:00 arr 12:00, flight operated, pax not aboard. Gate 3: No Travel. Gate 4: MSL = AC 330. Gate 5: AC operated ? YES. Gate 6: DENIED_BOARDING = TRUE ? NOT ELIGIBLE under FD flow (short-circuits Gates 7�10). Scope exclusion � customer may be eligible under APPR Sections 10�11 via Customer Relations: <6hr = CAN$900/CAN$1,000 EMD; 6�<9hr = CAN$1,800/CAN$2,000 EMD; ?9hr = CAN$2,400/CAN$2,700 EMD. Compensation (FD): $0. Fraud: NOT INVOKED. IDV: NOT REQUIRED. Payment: N/A. APPR = NE-06; EU = N/A; ASL = N/A.