Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight from Toronto to Tel Aviv was delayed about 4 hours due to severe weather. I'd like to check if I'm eligible for compensation"

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
And the user provides "Adi Carmel"
Then the chatbot responds:
"Thanks, Adi! And, what is your booking reference number?"
And the user provides "PNR: TC138"
Then the chatbot searches Trip Tracer for PNR: TC138
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer

AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:

Email: a***@gmail.com

Phone: +1***345

And the user selects "Email: a***@gmail.com"
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
"I found 1 passenger on this booking:

Adi Carmel (Adult)

Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED

JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:

Flight: AC 085

Route: Toronto (YYZ) ? Tel Aviv Ben Gurion (TLV)

Date: June 10, 2026

Arrival Delay: 4 hours

Is this the journey you'd like to check?"
And the user confirms "Yes"

SEGMENT CHECK:
Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18

DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for this passenger + journey combination

72-HOUR CHECK:
Then the chatbot checks: Hours since last leg arrival
And the system calculates: Arrival was June 10, 2026; current date is June 25, 2026 ? >72 hours ? PROCEED

CLAIM TIME LIMIT CHECK:
Then the chatbot checks: Filing deadline for ASL = 1,460 days (4 years) from MSL scheduled departure date ? within limitation ? PROCEED

REGIME DETERMINATION:
Then the system determines applicable regime:
And the system checks: Destination airport = TLV (Tel Aviv, Israel) ? Israel destination
And the system determines: ASL (Israel Aviation Services Law) applies (ASL covers flights to/from Israel)
And the system checks: Origin = YYZ (Canada) ? APPR also applies

TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS Evaluates and sends to Trip Tracer UI:

Trip Tracer UI Validation
Then the tester opens Trip Tracer UI for PNR: TC138

? Promised Itinerary - Flight: AC 085, Route: YYZ ? TLV, Scheduled Arrival: 16:00 (local TLV)

? Current Itinerary - Flight: AC 085, Route: YYZ ? TLV, Status: ARRIVED LATE, Actual: 20:00, Delay: +4H 00M

? Regime: ASL (Israel destination � TLV) + APPR (Canadian origin � YYZ)

? Destination: TLV (Israel)

? MSL FLIGHT: AC 085 � YYZ ? TLV

? Arrival Delay Code: 72 � numeric delay code (NOT a cancellation code � this is a delay scenario where the flight operated)

? "Delayed due to severe weather (thunderstorm)"

? EXTRAORDINARY CIRCUMSTANCE (delay code 72 in Extraordinary Circumstance list: 71, 72, 73, 75, 76, 77)

? Delay: +4H 00M

? ASL: Extraordinary Circumstance ? NOT ELIGIBLE (airline exempt)

? ASL Travel Completed Threshold: 8 hours ? 4hrs < 8hrs ? also below threshold (double NE reason)

? Fallback: FALSE (arrival delay code 72 available � Gate 9 uses arrival delay code per priority order)

? Sister City: FALSE

? CRITICAL: 4hr delay is below the 8hr ASL Travel Completed threshold AND arrival delay code 72 = Extraordinary Circumstance. Even if the code were controllable (Not Extraordinary Circumstance), 4hrs < 8hrs would still be NE. Weather is outside airline control regardless of delay duration.

Flight Compensation:

? MR ADI CARMEL | NOT ELIGIBLE | EXTRAORDINARY_CIRCUMSTANCE | ILS 0.00

FRAUD SCREENING � NOT TRIGGERED:
CyberSource is ONLY called for ELIGIBLE cases ? NOT invoked

NOT ELIGIBLE RESULT (FD-05b):
Then the chatbot displays:
"I've reviewed the details of your flight. I understand your flight AC 085 from Toronto (YYZ) to Tel Aviv Ben Gurion (TLV) on June 10, 2026 was delayed by 4 hours. However, you are not eligible for compensation at this time. After a full review, we can confirm that severe weather was the primary reason. Since the delay was caused by extraordinary circumstances beyond the airline's control, compensation is not required under the applicable regulations. If you have travel insurance, you may want to contact your insurance provider to see if your policy offers any coverage for this situation."

NO PAYMENT FLOW (skipped entirely for not eligible)
NO IDV (not required for not eligible)
CASE CREATION (GLOB-09):
Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your claim details."
And an alert information is displayed: "Claim submission successful!"
And the system appends the booking record to the case automatically

NOTIFICATION (Adobe):
Then the system triggers notification via Adobe:
And a Not Eligible notification email is sent to a***@gmail.com
And the email contains: Case Reference, flight details (AC 085 YYZ?TLV, delayed 4h), not eligible reason (Extraordinary Circumstance � severe weather, arrival delay code 72), regulation reference (ASL � Israel Aviation Services Law), insurance suggestion, contact information

END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"

I would like you to � new flow

No

And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given the case has been created for claimant "Adi Carmel" with PNR "TC138"
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
    And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
    And the Case Status should be "Closed � Not Eligible"
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be correct
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel should NOT be greyed out
    And the Claimant Name should be "Adi Carmel"
    And the Claimant Type should be "Adult"
    And the Authentication should be "Pass"
    And the PNR should be "TC138"
    And the PNR Creation Date should be populated
    And the Journey ID should be populated
    And the Booking Source should be populated
    And the Booking Office ID should be populated
    And the Regime should be "ASL (Israel destination � TLV) + APPR"
    And the Full Name should be "Adi Carmel"
    And the Tags should include "Claimant" and "Adult"
    And the Email should be "a***@gmail.com"
    And the Phone should be "+1***345"
    And the Address should be populated
    And the Aeroplan should be "Not linked"
    And the Profile ID should be populated
    And the Tier Status should be populated
    And the Journey should show "Bound 1: YYZ ? TLV" with claim filed for this flight as arrived late plus 4h
    And the Ancillary Fee section should be present
    And the expected ancillary fees should be none
    And the Eligibility and Compensation section should be present and show "NOT ELIGIBLE" with reason "Extraordinary Circumstance � severe weather, arrival delay code 72 � ASL"
    And the Double NE reason should show first Extraordinary Circumstance airline exempt and second 4hrs less than 8hr ASL Travel Completed threshold
    And even if controllable 4hrs would still be NE under ASL as below 8hr threshold
    And the Decision Assist Panel should auto-appear for FD topic
    And DDS should have run automatically with no agent action needed
    And the eligibility decision should be pre-populated as "NOT ELIGIBLE" due to Extraordinary Circumstance with arrival delay code 72 and weather and delay 4h and Israel destination TLV
    And the Fallback flag should be FALSE as arrival code is available Code 72
    And the Sister City flag should be FALSE
    And the Duplicate Check should have run automatically using baseline data "Adi Carmel + TC138 + YYZ?TLV + FD"
    And the result should be "No duplicate found"
    And no Duplicate Warning Banner should be displayed
    And the Related Cases tab should show no related cases
    And CyberSource should NOT have been triggered as it only runs for eligible cases
    And the system should have appended the booking record automatically for identified and authenticated user
    And Trip Tracer poll should NOT be required
    And the agent should have used pull case from My Activities
    And the case status should have transitioned from "Assigned" to "In Progress"
    And a case acknowledgement notification should have been sent
    And a not eligible notification email should have been sent via Adobe to "a***@gmail.com" containing Case Reference and flight details AC 085 YYZ to TLV delayed 4h and Extraordinary Circumstance severe weather arrival delay code 72 and ASL and insurance suggestion and contact information
    And the Agent Notes section should be accessible
    And the Audit Log should record all actions with timestamps and before/after values
    And Customer Communications should show the not eligible notification email chronologically
    And the chatbot transcript should be accessible and linked to the case
    And the Attachments tab should be empty
    And the Final Status should be "Closed � Not Eligible"
    And the case should be in read-only mode with no editable Decision Assist fields
    And the agent should not be able to access Case Search as it is for leads and management only

PAYMENT VALIDATION
    Given the eligibility result is "NOT ELIGIBLE" due to Extraordinary Circumstance and below 8hr threshold
    Then no payment flow should be triggered
    And no country of residence should have been asked
    And no compensation record should have been created
    And no batch file should have been dispatched
    And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section

Expected Results:
DDS returns FD-ASL-NE-24. Trip Tracer: Promise = 16:00; Actual = 20:00; Delay = 4hrs; MSL = Leg 1 (AC 084); Code 72 (Weather); Extraordinary; Fallback = FALSE. CRITICAL: 4hr delay meets threshold but Code 72 = Extraordinary ? $0. Weather is outside airline control regardless of delay duration. Compensation: $0. Fraud Screening: NOT INVOKED. Regime Assessment: ASL = NE-24 (Extraordinary, Weather, Delay at Arrival); APPR = NE (Uncontrollable); EU = N/A. Claims Dashboard: Travel Completed; Code 72 (Weather, Extraordinary); Delay = 4hrs (would be eligible if controllable); $0; DDS = FD-ASL-NE-24.