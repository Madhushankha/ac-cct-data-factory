Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight from Toronto to Paris was delayed about 4 hours due to a crew issue. I'd like to check if I'm eligible for compensation under EU regulations"

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
And the user provides "Robert Tremblay"
Then the chatbot responds:
"Thanks, Robert! And, what is your booking reference number?"
And the user provides "PNR: TC108"
Then the chatbot searches Trip Tracer for PNR: TC108
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer

AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:

Email: r***@gmail.com

Phone: +1***123

And the user selects "Email: r***@gmail.com"
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

Robert Tremblay (Adult)

Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED

JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:

Flight: AC 870

Route: Toronto (YYZ) ? Paris Charles de Gaulle (CDG)

Date: June 3, 2026

Arrival Delay: 4 hours

Is this the journey you'd like to check?"
And the user confirms "Yes"

SEGMENT CHECK:
Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18

DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for this passenger + journey combination

72-HOUR CHECK:
Then the chatbot checks: Hours since last leg arrival ? >72 hours ? PROCEED

CLAIM TIME LIMIT CHECK:
Then the chatbot checks: Filing deadline ? within limitation ? PROCEED

REGIME DETERMINATION:
Then the system determines applicable regime:
And the system checks: Origin airport = YYZ (Toronto, Canada) ? NOT EU origin
And the system checks: Destination airport = CDG (Paris, EU) ? EU destination but NOT EU origin
And the system checks: Operating carrier = AC (Canadian) ? NOT EU-based carrier
And the system determines: EU 261 (EU Mainland) does NOT apply � EU 261 requires EU origin for flights on any carrier; for flights arriving in EU, the operating carrier must be EU-based (e.g., Air France for CDG). AC is Canadian ? excluded.
And the system checks: Does APPR apply? ? YES (Canadian origin, AC operated) ? APPR assessed separately
And the system determines: Under EU 261 specifically ? NOT ELIGIBLE (not EU origin + non-EU carrier)

TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS Evaluates and sends to Trip Tracer UI:

Trip Tracer UI Validation
Then the tester opens Trip Tracer UI for PNR: TC108

? Promised Itinerary - Flight: AC 870, Route: YYZ ? CDG, Scheduled Arrival: 08:00 (local CDG)

? Current Itinerary - Flight: AC 870, Route: YYZ ? CDG, Status: ARRIVED LATE, Actual: 12:00, Delay: +4H 00M

? Origin: YYZ (Toronto, Canada) ? NOT EU ORIGIN

? Destination: CDG (Paris, EU) ? EU destination only

? Carrier: AC (Canadian � NOT EU-based)

? Regime Check: EU 261 requires EU origin ? YYZ is NOT EU ? EU 261 DOES NOT APPLY

? Regime Check (arrival rule): Destination CDG is EU, BUT carrier AC is NOT EU-based ? EU arrival rule also does NOT apply

? APPR: May apply separately (Canadian origin, AC operated)

? Arrival Delay Code: 42 � numeric delay code (NOT a cancellation code � this is a delay scenario)

? CONTROLLABLE (delay code 42 in controllable list)

? EU 261 Assessment: NOT ELIGIBLE (itinerary not EU origin; non-EU carrier arriving in EU)

Flight Compensation (EU 261):

? MR ROBERT TREMBLAY | NOT ELIGIBLE | NOT_EU_ORIGIN | EUR 0.00

FRAUD SCREENING � NOT TRIGGERED:
CyberSource is ONLY called for ELIGIBLE cases ? NOT invoked

NOT ELIGIBLE RESULT (FD-05b) � EU 261 specific:
Then the chatbot displays:
"I've reviewed the details of your flight. I understand your flight AC 870 from Toronto (YYZ) to Paris Charles de Gaulle (CDG) was delayed by 4 hours. However, EU Air Passenger Rights regulations (EU 261/2004) apply to flights departing from EU airports. Since your flight originated from Canada, the EU 261 regulation does not apply to this journey. Your claim will be assessed under the applicable Canadian Air Passenger Protection Regulations (APPR)."

NO PAYMENT FLOW (skipped for EU 261 not eligible)
NO IDV (not required for not eligible)
CASE CREATION (GLOB-09):
Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your claim details."
And an alert information is displayed: "Claim submission successful!"
And the system appends the booking record to the case automatically

NOTIFICATION (Adobe):
Then the system triggers notification via Adobe:
And a notification email is sent to r***@gmail.com
And the email contains: Case Reference, flight details (YYZ?CDG, delayed 4h), not eligible reason under EU 261 (not EU origin, non-EU carrier), note about APPR assessment, contact information

END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"

I would like you to � new flow

No

And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given the case has been created for claimant "Robert Tremblay" with PNR "TC108"
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
    And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
    And the Case Status should be "Closed � Not Eligible"
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be correct
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel should NOT be greyed out
    And the Claimant Name should be "Robert Tremblay"
    And the Claimant Type should be "Adult"
    And the Authentication should be "Pass"
    And the PNR should be "TC108"
    And the PNR Creation Date should be populated
    And the Journey ID should be populated
    And the Booking Source should be populated
    And the Booking Office ID should be populated
    And the Regime should be "EU 261 � BUT not EU origin so does not apply"
    And the Full Name should be "Robert Tremblay"
    And the Tags should include "Claimant" and "Adult"
    And the Email should be "r***@gmail.com"
    And the Phone should be "+1***123"
    And the Address should be populated
    And the Aeroplan should be "Not linked"
    And the Profile ID should be populated
    And the Tier Status should be populated
    And the Journey should show "Bound 1: YYZ ? CDG" with claim filed for this flight as arrived late plus 4h
    And the Ancillary Fee section should be present
    And the expected ancillary fees should be none
    And the Eligibility and Compensation section should be present and show "NOT ELIGIBLE" with reason "Itinerary not EU origin � YYZ is Canada, not EU; EU 261 requires EU origin; carrier AC is not EU-based so EU arrival rule also N/A"
    And the Decision Assist Panel should auto-appear for FD topic
    And DDS should have run automatically with no agent action needed
    And the eligibility decision should be pre-populated as "NOT ELIGIBLE" due to not EU origin with EU 261 not applying and APPR may apply separately
    And the Duplicate Check should have run automatically using baseline data "Robert Tremblay + TC108 + YYZ?CDG + FD"
    And the result should be "No duplicate found"
    And CyberSource should NOT have been triggered
    And the system should have appended the booking record automatically
    And a notification email should have been sent to "r***@gmail.com" containing not eligible under EU 261 due to not EU origin and non-EU carrier and note about APPR assessment
    And the Final Status should be "Closed � Not Eligible"
    And the case should be in read-only mode
    And the agent should not be able to access Case Search as it is for leads and management only

PAYMENT VALIDATION
    Given the eligibility result is "NOT ELIGIBLE" due to not EU origin
    Then no payment flow should be triggered
    And no country of residence should have been asked
    And no compensation record should have been created
    And no batch file should have been dispatched
    And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section

Expected Results:
DDS returns FD-EU-NE-19. Trip Tracer: Flight operated; Arrival delay = 4hrs; Arrival Delay Code 42 (numeric delay code � Controllable); Origin YYZ (Canada) � NOT EU ? EU 261 departure rule N/A; Destination CDG (France, EU) � EU arrival, BUT carrier AC is NOT EU-based ? EU 261 arrival rule N/A. CRITICAL: To be covered by EU 261 when arriving in EU, the operating carrier must be EU-based (e.g., Air France for CDG). AC is Canadian ? excluded. EU 261 = NOT APPLICABLE (route exclusion � not EU origin + non-EU carrier). APPR applies separately (Canadian origin, AC operated). Result: NOT ELIGIBLE under EU 261, �0. CyberSource: NOT triggered. Payment: NONE. DDS = FD-EU-NE-19.