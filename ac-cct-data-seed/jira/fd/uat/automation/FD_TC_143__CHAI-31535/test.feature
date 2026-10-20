Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "I flew from Paris to Toronto but my connecting flight from Toronto to Vancouver was disrupted. I'm stuck in Toronto � I didn't go back to Paris and I never made it to Vancouver. Can I get compensation?"

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
And the user provides "Damien Leroy"
Then the chatbot responds:
"Thanks, Damien! And, what is your booking reference number?"
And the user provides "PNR: TC104"
Then the chatbot searches Trip Tracer for PNR: TC104
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer

AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:

Email: d***@gmail.com

Phone: +33***678

And the user selects "Email: d***@gmail.com"
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

Damien Leroy (Adult)

Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED

JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:

Segment 1: Flight AC 871, Paris Charles de Gaulle (CDG) ? Toronto (YYZ), May 30, 2026 � COMPLETED

Segment 2: Flight AC 121, Toronto (YYZ) ? Vancouver (YVR), May 30, 2026 � CANCELLED

Is this the journey you'd like to check?"
And the user confirms "Yes"

SEGMENT CHECK (GenUC-18):
Then the chatbot checks: More than 1 segment on selected journey? ? YES (2 segments)
Then the chatbot identifies: Segment 1 COMPLETED, Segment 2 CANCELLED
Then the chatbot determines: Claim applies to Segment 2 (AC 121 YYZ?YVR � CANCELLED)

DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for this passenger + journey combination

72-HOUR CHECK:
Then the chatbot checks: Hours since scheduled departure of Leg 2
And the system calculates: Scheduled departure was May 30, 2026; current date is June 25, 2026 ? >72 hours ? PROCEED

CLAIM TIME LIMIT CHECK:
Then the chatbot checks: Filing deadline for EU 261 (French jurisdiction � CDG origin) = 5 years ? within limitation ? PROCEED

REGIME DETERMINATION:
Then the system determines: Journey origin = CDG (Paris, EU Mainland) ? EU 261 (EU Mainland)
And the system checks: Customer stuck at midpoint (YYZ), never reached YVR, did not return to CDG ? No Travel Incomplete

TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS Evaluates and sends to Trip Tracer UI:

Trip Tracer UI Validation
Then the tester opens Trip Tracer UI for PNR: TC104

? Segment 1: Flight: AC 871, Route: CDG ? YYZ, Status: COMPLETED (on time)

? Segment 2: Flight: AC 121, Route: YYZ ? YVR, Status: CANCELLED (claim filed)

? Cancellation Code on Leg 2: CREW � 4-character Netline code

? "Cancellation � crew unavailability"

? CONTROLLABLE (CREW in Controllable list)

? MSL Delay on Leg 2 (re-routing): 2H 00M ? BELOW 3-HOUR EU 261 THRESHOLD (Gate 8)

? Customer Status: NO TRAVEL - INCOMPLETE (stranded at YYZ � did not return to CDG, did not reach YVR)

? History - Customer stranded at mid-point YYZ; no rebooking; no return to origin

? Regime: EU 261 (EU Mainland � CDG origin)

? EU 261 Threshold: Arrival delay must be ? 3 hours ? 2h < 3h ? NOT ELIGIBLE

? Fallback: FALSE (cancellation code CREW available)

Flight Compensation:

? MR DAMIEN LEROY | NOT ELIGIBLE | DELAY_BELOW_3_HOURS | EUR 0.00

FRAUD SCREENING � NOT TRIGGERED:
CyberSource is ONLY called for ELIGIBLE cases ? NOT invoked

NOT ELIGIBLE RESULT (FD-05b):
Then the chatbot displays:
"I've checked your flight details, and it looks like your arrival in Vancouver was on time. That means there's no recorded delay for this part of your trip. Based on the EU Air Passenger Rights regulations (EU 261/2004), you are not entitled to compensation at this time."

NO PAYMENT FLOW (skipped entirely for not eligible)
NO IDV (not required for not eligible)
CASE CREATION (GLOB-09):
Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your claim details."
And an alert information is displayed: "Claim submission successful!"
And the system appends the booking record to the case automatically

NOTIFICATION (Adobe):
Then the system triggers notification via Adobe:
And a Not Eligible notification email is sent to d***@gmail.com
And the email contains: Case Reference, flight details (Leg 2: YYZ?YVR CANCELLED), not eligible reason (MSL delay below 3-hour threshold despite controllable cancellation code CREW), travel status (No Travel - Incomplete), regulation reference (EU 261), contact information

END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"

I would like you to � new flow

No

And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given the case has been created for claimant "Damien Leroy" with PNR "TC104"
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Cancellation"
    And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
    And the Case Status should be "Closed � Not Eligible"
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be correct
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel should NOT be greyed out
    And the Claimant Name should be "Damien Leroy"
    And the Claimant Type should be "Adult"
    And the Authentication should be "Pass"
    And the PNR should be "TC104"
    And the PNR Creation Date should be populated
    And the Journey ID should be populated
    And the Booking Source should be populated
    And the Booking Office ID should be populated
    And the Regime should be "EU 261 (EU Mainland)"
    And the Full Name should be "Damien Leroy"
    And the Tags should include "Claimant" and "Adult"
    And the Email should be "d***@gmail.com"
    And the Phone should be "+33***678"
    And the Address should be populated
    And the Aeroplan should be "Not linked"
    And the Profile ID should be populated
    And the Tier Status should be populated
    And the Journey should show "Segment 1: CDG ? YYZ" as completed and "Segment 2: YYZ ? YVR" with claim filed for this flight as cancelled
    And the Ancillary Fee section should be present
    And the expected ancillary fees should be none
    And the Eligibility and Compensation section should be present and show "NOT ELIGIBLE" with reason "MSL delay 2h on Leg 2 � below EU 261 minimum 3-hour threshold; cancellation code CREW = Controllable but threshold overrides; No Travel Incomplete; stranded at YYZ"
    And the Decision Assist Panel should auto-appear for FD topic
    And DDS should have run automatically with no agent action needed
    And the eligibility decision should be pre-populated as "NOT ELIGIBLE" due to delay 2h being less than 3h EU 261 threshold with No Travel Incomplete
    And the Duplicate Check should have run automatically using baseline data "Damien Leroy + TC104 + CDG?YVR + FD"
    And the result should be "No duplicate found"
    And no Duplicate Warning Banner should be displayed
    And the Related Cases tab should show no related cases
    And CyberSource should NOT have been triggered as it only runs for eligible cases
    And the system should have appended the booking record automatically for identified and authenticated user
    And Trip Tracer poll should NOT be required
    And the agent should have used pull case from My Activities
    And the case status should have transitioned from "Assigned" to "In Progress"
    And a case acknowledgement notification should have been sent
    And a not eligible notification email should have been sent via Adobe to "d***@gmail.com" containing Case Reference and Leg 2 YYZ to YVR CANCELLED and not eligible reason MSL delay below 3h despite controllable CREW and No Travel Incomplete and EU 261
    And the Agent Notes section should be accessible
    And the Audit Log should record all actions with timestamps and before/after values
    And Customer Communications should show the not eligible notification email chronologically
    And the chatbot transcript should be accessible and linked to the case
    And the Attachments tab should be empty
    And the Final Status should be "Closed � Not Eligible"
    And the case should be in read-only mode with no editable Decision Assist fields
    And the agent should not be able to access Case Search as it is for leads and management only

PAYMENT VALIDATION
    Given the eligibility result is "NOT ELIGIBLE" due to MSL delay below 3-hour threshold on Leg 2
    Then no payment flow should be triggered
    And no country of residence should have been asked
    And no compensation record should have been created
    And no batch file should have been dispatched
    And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section

Expected Results:
DDS returns FD-EU-NE-15. Trip Tracer: Leg 1 = Completed; Leg 2 = CANCELLED; MSL = Leg 2 (AC 121 YYZ?YVR); Cancellation Code = CREW; Re-routing delay = 2hrs (below 3hr threshold � Gate 8); No Travel = Incomplete (stranded at YYZ � did not reach YVR, did not return to CDG); Fallback = FALSE ; EU 261 (EU Mainland � CDG origin). Threshold overrides controllability and all other eligible conditions. Result: NOT ELIGIBLE, �0. CyberSource: NOT triggered. IDV: NOT required. Payment: NONE. Claims Dashboard: EU Mainland NE-15; NOT ELIGIBLE; Delay Below Threshold (2hrs < 3hrs); Cancellation Code = CREW (Controllable); No Travel = Incomplete; Stranded = YYZ; Multi-leg (CDG?YYZ?YVR); DDS = FD-EU-NE-15.