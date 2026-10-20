Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight was delayed about 5 hours due to bad weather, I'd like to check if my family and I are eligible for compensation"
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
And the user provides "Philippe Tremblay"
Then the chatbot responds:
"Thanks, Philippe! And, what is your booking reference number?"
And the user provides "PNR: TC052"
Then the chatbot searches Trip Tracer for PNR: TC052
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer

AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
� Email: p***@gmail.com
� Phone: +1***901
And the user selects "Email: p***@gmail.com"
Then the chatbot responds:
"I've sent a verification code to your email, please enter it within 15 minutes of receiving it."
And the user provides the OTP code "629184"
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
"I found 2 passengers on this booking:
� Philippe Tremblay (Adult - Aeroplan Member)
� Sophie Tremblay (Adult)
Who would you like to include in your claim?"
And the user confirms "Both passengers"
Then the chatbot checks: PAX count on PNR = 2 ? ?9 ? NOT a group booking ? PROCEED

JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
� Flight: AC 365
� Route: Toronto (YYZ) ? Vancouver (YVR)
� Date: June 5, 2026
� Arrival Delay: 5 hours
Is this the journey you'd like to check?"
And the user confirms "Yes"

SEGMENT CHECK:
Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18

DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for Philippe Tremblay + TC052 + YYZ?YVR + FD
And Case Services returns: NO existing case found for Sophie Tremblay + TC052 + YYZ?YVR + FD

72-HOUR CHECK:
Then the chatbot checks: Hours since last leg arrival
And the system calculates: Arrival was June 5, 2026; current date is June 15, 2026 ? >72 hours ? PROCEED

CLAIM TIME LIMIT CHECK:
Then the chatbot checks: Filing deadline for APPR = 366 days from disruption
And the system calculates: Disruption June 5, 2026; filing June 15, 2026 ? 10 days ? within 366 days ? PROCEED

TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS Evaluates and sends to Trip Tracer UI:

TRIP TRACER UI VALIDATION
Then the tester opens Trip Tracer UI for PNR: TC052
? Promised Itinerary - Flight: AC 365, Route: YYZ ? YVR, Scheduled Arrival: 14:00
? Current Itinerary - Flight: AC 365, Route: YYZ ? YVR, Status: ARRIVED LATE, Scheduled Arrival: 14:00 ? Actual: 19:00, Delay: +5H 00M
? Regime: APPR (1 regime)
? MSL FLIGHT: AC 365 � YYZ ? YVR � 71
? "Delayed due to severe weather (snowstorm)"
? Delay: +5H 00M � UNCONTROLLABLE
? APPR Gate 8: Delay 5h ? 3h ? PASSES threshold
? APPR Gate 9: Code 71 = Uncontrollable ? NOT ELIGIBLE
? Fallback: FALSE
Flight Compensation:
  ? MR PHILIPPE TREMBLAY | NOT ELIGIBLE | UNCONTROLLABLE | CAD 0.00
  ? MS SOPHIE TREMBLAY | NOT ELIGIBLE | UNCONTROLLABLE | CAD 0.00

FRAUD SCREENING � NOT TRIGGERED:
Then the chatbot notes: CyberSource is ONLY called for ELIGIBLE cases
And this case is NOT ELIGIBLE for all passengers ? CyberSource NOT invoked

NOT ELIGIBLE RESULT (FD-05b):
Then the chatbot displays:
"I've reviewed the details of your flight for all passengers on your booking. I understand your departure from Toronto was delayed by 5 hours. However, you are not eligible for expense reimbursement for this delay. After a full review, we can confirm that severe weather (snowstorm) was the primary reason. Since the delay was caused by weather conditions outside of the airline's control, it is not covered under the compensation regulations (APPR). If you have travel insurance, you may want to contact your insurance provider to see if your policy offers any coverage for this situation."

NO PAYMENT FLOW (skipped entirely � not eligible for all passengers)
NO IDV (not required � not eligible case)
NOTE: AC Wallet is NOT offered even though Philippe Tremblay has a Basic Aeroplan account linked, as no compensation is payable for uncontrollable disruptions.

CASE CREATION (GLOB-09):
Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your claim details."
And an alert information is displayed: "Claim submission successful!"
And the system appends the booking record to the case automatically for both passengers

NOTIFICATION (Adobe):
Then the system triggers notification via Adobe:
And a Not Eligible notification email is sent to p***@gmail.com
And the email contains: Case Reference, flight details (AC 365 YYZ?YVR), not eligible reason (uncontrollable � severe weather, Code 71), all passengers listed (Philippe Tremblay, Sophie Tremblay), regulation reference (APPR), contact information

END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given the case has been created for claimant "Philippe Tremblay" with PNR "TC052"
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
    And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
    And the Case Status should be "Closed � Not Eligible"
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be correct
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel should NOT be greyed out
    And the Claimant Name should be "Philippe Tremblay"
    And the Claimant Type should be "Adult"
    And the Authentication should be "Pass"
    And the PNR should be "TC052"
    And the PNR Creation Date should be populated
    And the Journey ID should be populated
    And the Booking Source should be populated
    And the Booking Office ID should be populated
    And the Regime should be "APPR"
    And the Full Name should be "Philippe Tremblay"
    And the Tags should include "Claimant" and "Adult"
    And the Email should be "p***@gmail.com"
    And the Phone should be "+1***901"
    And the Address should be populated
    And the Aeroplan should be "9876543210" linked and in good standing (Basic Member)
    And the Profile ID should be populated
    And the Tier Status should be "Basic / Member"
    And the second passenger "Sophie Tremblay" should appear in the passenger panel as "Adult" with no Aeroplan linked
    And the Journey should show "Bound 1: YYZ ? YVR" with claim filed for both passengers
    And the Ancillary Fee section should be present
    And the expected ancillary fees should be none
    And the Eligibility and Compensation section should be present and show "NOT ELIGIBLE" for both Philippe Tremblay and Sophie Tremblay with reason "Uncontrollable � weather, Code 71"
    And the Decision Assist Panel should auto-appear for FD topic
    And DDS should have run automatically
    And the eligibility decision should be pre-populated as "NOT ELIGIBLE" for all passengers � delay 5h passes Gate 8 threshold but Code 71 is Uncontrollable at Gate 9
    And the Duplicate Check should have run automatically using baseline data "Philippe Tremblay + TC052 + YYZ?YVR + FD" and "Sophie Tremblay + TC052 + YYZ?YVR + FD"
    And the result should be "No duplicate found" for both passengers
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
    Given the eligibility result is "NOT ELIGIBLE" due to uncontrollable weather Code 71 for all 2 passengers
    Then no payment flow should be triggered for any passenger
    And no country of residence should have been asked
    And no compensation record should have been created for Philippe Tremblay or Sophie Tremblay
    And no batch file should have been dispatched
    And AC Wallet should NOT have been offered to Philippe Tremblay despite having a linked Basic Aeroplan account (9876543210) � AC Wallet is only offered for eligible cases
    And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" for all passengers with no compensation record and no payout section

Expected Results:
DDS returns FD-APPR-NE-28 for all passengers. Trip Tracer: Promise = 14:00; Actual = 19:00; Delay = 5hrs; MSL = Leg 1 (AC 365 YYZ?YVR); Code 71 (Weather � snowstorm); Uncontrollable; Fallback = FALSE; APPR. Passengers: Philippe Tremblay (Basic Aeroplan 9876543210) � NOT ELIGIBLE; Sophie Tremblay (no Aeroplan) � NOT ELIGIBLE. CRITICAL: 5hr delay meets Tier 1 threshold (?3hrs) BUT Code 71 = Uncontrollable ? $0 for all passengers. Delay duration is irrelevant when cause is uncontrollable. AC Wallet NOT offered despite Aeroplan linkage � no compensation payable. Compensation: $0 per passenger. Fraud Screening: NOT INVOKED. Payment: N/A. Regime Assessment: APPR = NE-28; EU = N/A; ASL = N/A. Claims Dashboard: Code 71 (Weather, Uncontrollable); Delay = 5hrs (would be Tier 1 per pax if controllable); $0 for all; DDS = FD-APPR-NE-28.Case Header: