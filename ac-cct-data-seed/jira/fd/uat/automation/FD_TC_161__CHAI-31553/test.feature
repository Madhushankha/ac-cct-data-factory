Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "I flew from Toronto to Frankfurt but my connecting flight from Frankfurt to Tel Aviv was disrupted. I'm stuck in Frankfurt � I didn't go back to Toronto and I never made it to Tel Aviv. Can I get compensation?"

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
And the user provides "Nirit Golan"
Then the chatbot responds:
"Thanks, Nirit! And, what is your booking reference number?"
And the user provides "PNR: TC130"
Then the chatbot searches Trip Tracer for PNR: TC130
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer

AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:

Email: n***@outlook.com

Phone: +1***567

And the user selects "Email: n***@outlook.com"
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

Nirit Golan (Adult)

Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED

JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:

Segment 1: Flight AC 873, Toronto (YYZ) ? Frankfurt (FRA), June 2, 2026 � COMPLETED

Segment 2: Flight AC 9042, Frankfurt (FRA) ? Tel Aviv Ben Gurion (TLV), June 2, 2026 � CANCELLED

Is this the journey you'd like to check?"
And the user confirms "Yes"

SEGMENT CHECK (GenUC-18):
Then the chatbot checks: More than 1 segment on selected journey? ? YES (2 segments)
Then the chatbot identifies: Segment 1 COMPLETED, Segment 2 CANCELLED
Then the chatbot determines: Claim applies to Segment 2 (AC 9042 FRA?TLV � CANCELLED)

DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for this passenger + journey combination

72-HOUR CHECK:
Then the chatbot checks: Hours since scheduled departure of Leg 2
And the system calculates: Scheduled departure was June 2, 2026; current date is June 25, 2026 ? >72 hours ? PROCEED

CLAIM TIME LIMIT CHECK:
Then the chatbot checks: Filing deadline for ASL = 1,460 days (4 years) from MSL scheduled departure date ? within limitation ? PROCEED

REGIME DETERMINATION:
Then the system determines applicable regime:
And the system checks: Destination airport = TLV (Tel Aviv, Israel) ? Israel destination
And the system determines: ASL (Israel Aviation Services Law) applies
And the system checks: Origin = YYZ (Canada) ? APPR also applies
And the system checks: Flight CANCELLED but re-routing delay = 2hrs ? below 3hr No Travel threshold
And the system checks: Customer stuck at midpoint (FRA), never reached TLV, did not return to YYZ ? No Travel Incomplete

TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS Evaluates and sends to Trip Tracer UI:

Trip Tracer UI Validation
Then the tester opens Trip Tracer UI for PNR: TC130

? Segment 1: Flight: AC 873, Route: YYZ ? FRA, Status: COMPLETED (on time)

? Segment 2: Flight: AC 9042, Route: FRA ? TLV, Status: CANCELLED (claim filed)

? Cancellation Code on Leg 2: CREW � 4-character Netline code

? "Cancellation � crew unavailability"

? NOT EXTRAORDINARY CIRCUMSTANCE (CREW in controllable list)

? MSL Delay on Leg 2 (re-routing): 2H 00M ? BELOW 3-HOUR ASL NO TRAVEL THRESHOLD (Gate 8)

? Customer Status: NO TRAVEL - INCOMPLETE (stranded at FRA � did not return to YYZ, did not reach TLV)

? History - Customer stranded at mid-point FRA; no rebooking accepted; no return to origin

? Regime: ASL (Israel destination � TLV) + APPR (Canadian origin � YYZ)

? ASL No Travel Threshold: MSL delay must be ? 3 hours ? 2h < 3h ? NOT ELIGIBLE

? Fallback: FALSE (cancellation code CREW available)

? CRITICAL: Despite controllable cancellation code CREW on Israel-bound route, re-routing delay is below 3hr threshold ? NOT ELIGIBLE. Threshold overrides controllability.

Flight Compensation:

? MS NIRIT GOLAN | NOT ELIGIBLE | DELAY_BELOW_3_HOURS | ILS 0.00

FRAUD SCREENING � NOT TRIGGERED:
CyberSource is ONLY called for ELIGIBLE cases ? NOT invoked

NOT ELIGIBLE RESULT (FD-05b):
Then the chatbot displays:
"I've checked your flight details, and it looks like your arrival in Tel Aviv was on time. That means there's no recorded delay for this part of your trip. Based on the applicable regulations, you are not entitled to compensation at this time."

NO PAYMENT FLOW (skipped entirely for not eligible)
NO IDV (not required for not eligible)
CASE CREATION (GLOB-09):
Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your claim details."
And an alert information is displayed: "Claim submission successful!"
And the system appends the booking record to the case automatically

NOTIFICATION (Adobe):
Then the system triggers notification via Adobe:
And a Not Eligible notification email is sent to n***@outlook.com
And the email contains: Case Reference, flight details (Leg 2: FRA?TLV CANCELLED), not eligible reason (MSL re-routing delay below 3-hour No Travel threshold despite controllable cancellation code CREW), travel status (No Travel - Incomplete), regulation reference (ASL), contact information

END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"

I would like you to � new flow

No

And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given the case has been created for claimant "Nirit Golan" with PNR "TC130"
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Cancellation"
    And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
    And the Case Status should be "Closed � Not Eligible"
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be correct
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel should NOT be greyed out
    And the Claimant Name should be "Nirit Golan"
    And the Claimant Type should be "Adult"
    And the Authentication should be "Pass"
    And the PNR should be "TC130"
    And the PNR Creation Date should be populated
    And the Journey ID should be populated
    And the Booking Source should be populated
    And the Booking Office ID should be populated
    And the Regime should be "ASL (Israel destination � TLV) + APPR"
    And the Full Name should be "Nirit Golan"
    And the Tags should include "Claimant" and "Adult"
    And the Email should be "n***@outlook.com"
    And the Phone should be "+1***567"
    And the Address should be populated
    And the Aeroplan should be "Not linked"
    And the Profile ID should be populated
    And the Tier Status should be populated
    And the Journey should show "Segment 1: YYZ ? FRA" as completed and "Segment 2: FRA ? TLV" as cancelled with claim filed
    And the Ancillary Fee section should be present
    And the expected ancillary fees should be none
    And the Eligibility and Compensation section should be present and show "NOT ELIGIBLE" with reason "MSL re-routing delay 2h on Leg 2 � below ASL minimum 3-hour No Travel threshold; cancellation code CREW = Not Extraordinary Circumstance but threshold overrides; No Travel Incomplete; stranded at FRA"
    And the Decision Assist Panel should auto-appear for FD topic
    And DDS should have run automatically with no agent action needed
    And the eligibility decision should be pre-populated as "NOT ELIGIBLE" due to delay 2h being less than 3h ASL No Travel threshold with No Travel Incomplete
    And the Duplicate Check should have run automatically using baseline data "Nirit Golan + TC130 + YYZ?TLV + FD"
    And the result should be "No duplicate found"
    And no Duplicate Warning Banner should be displayed
    And the Related Cases tab should show no related cases
    And CyberSource should NOT have been triggered as it only runs for eligible cases
    And the system should have appended the booking record automatically for identified and authenticated user
    And Trip Tracer poll should NOT be required
    And the agent should have used pull case from My Activities
    And the case status should have transitioned from "Assigned" to "In Progress"
    And a case acknowledgement notification should have been sent
    And a not eligible notification email should have been sent via Adobe to "n***@outlook.com" containing Case Reference and Leg 2 FRA to TLV CANCELLED and MSL delay below 3h and No Travel Incomplete and ASL
    And the Agent Notes section should be accessible
    And the Audit Log should record all actions with timestamps and before/after values
    And Customer Communications should show the not eligible notification email chronologically
    And the chatbot transcript should be accessible and linked to the case
    And the Attachments tab should be empty
    And the Final Status should be "Closed � Not Eligible"
    And the case should be in read-only mode with no editable Decision Assist fields
    And the agent should not be able to access Case Search as it is for leads and management only

PAYMENT VALIDATION
    Given the eligibility result is "NOT ELIGIBLE" due to MSL delay below 3-hour ASL threshold on Leg 2
    Then no payment flow should be triggered
    And no country of residence should have been asked
    And no compensation record should have been created
    And no batch file should have been dispatched
    And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section

Expected Results:
DDS returns FD-ASL-NE-16. Trip Tracer: Leg 1 = Completed; Leg 2 = CANCELLED; MSL = Leg 2 (AC 9042 FRA?TLV); Cancellation Code = CREW (4-char Netline � Not Extraordinary Circumstance / Controllable); Re-routing delay = 2hrs (below 3hr No Travel threshold � Gate 8); No Travel = Incomplete (stranded at FRA � did not reach TLV, did not return to YYZ); Fallback = FALSE; ASL (Israel destination � TLV) + APPR. Threshold overrides controllability. Result: NOT ELIGIBLE, ILS 0. CyberSource: NOT triggered. Payment: NONE. DDS = FD-ASL-NE-16.