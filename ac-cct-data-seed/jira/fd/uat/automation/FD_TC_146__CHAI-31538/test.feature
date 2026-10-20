Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight from Paris to Toronto was delayed about 4 hours due to severe weather. Can I get compensation?"

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
And the user provides "Julien Marchand"
Then the chatbot responds:
"Thanks, Julien! And, what is your booking reference number?"
And the user provides "PNR: TC112"
Then the chatbot searches Trip Tracer for PNR: TC112
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer

AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:

Email: j***@gmail.com

Phone: +33***234

And the user selects "Email: j***@gmail.com"
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

Julien Marchand (Adult)

Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED

JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:

Flight: AC 871

Route: Paris Charles de Gaulle (CDG) ? Toronto (YYZ)

Date: June 8, 2026

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
And the system calculates: Arrival was June 8, 2026; current date is June 25, 2026 ? >72 hours ? PROCEED

CLAIM TIME LIMIT CHECK:
Then the chatbot checks: Filing deadline for EU 261 (French jurisdiction � CDG origin) = 5 years ? within limitation ? PROCEED

REGIME DETERMINATION:
Then the system determines: Origin = CDG (Paris, EU Mainland) ? EU 261 (EU Mainland)
And the system checks: Distance CDG?YYZ = ~5,900 km ? Long-haul (>3500km)

TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS Evaluates and sends to Trip Tracer UI:

Trip Tracer UI Validation
Then the tester opens Trip Tracer UI for PNR: TC112

? Promised Itinerary - Flight: AC 871, Route: CDG ? YYZ, Scheduled Arrival: 16:00

? Current Itinerary - Flight: AC 871, Route: CDG ? YYZ, Status: ARRIVED LATE, Actual: 20:00, Delay: +4H 00M

? Regime: EU 261 (EU Mainland � CDG origin)

? Distance: CDG?YYZ = ~5,900 km ? Long-haul (>3500km)

? MSL FLIGHT: AC 871 � CDG ? YYZ

? Arrival Delay Code: 72 � numeric delay code (NOT a cancellation code � this is a delay scenario)

? "Delayed due to severe weather (thunderstorm)"

? UNCONTROLLABLE / EXTRAORDINARY CIRCUMSTANCES (delay code 72 in uncontrollable list)

? Delay: +4H 00M � meets 3hr threshold BUT extraordinary overrides

? EU 261: Extraordinary circumstances ? Article 5(3) exemption ? NOT ELIGIBLE

? Fallback: FALSE (arrival delay code 72 available)

? Sister City: FALSE

? CRITICAL: 4hr delay meets threshold AND long-haul distance band would normally = �600 if controllable. But delay code 72 = Extraordinary ? airline exempt under Article 5(3). Weather is outside airline control regardless of delay duration.

Flight Compensation:

? MR JULIEN MARCHAND | NOT ELIGIBLE | EXTRAORDINARY_CIRCUMSTANCES | EUR 0.00

FRAUD SCREENING � NOT TRIGGERED:
CyberSource is ONLY called for ELIGIBLE cases ? NOT invoked

NOT ELIGIBLE RESULT (FD-05b):
Then the chatbot displays:
"I've reviewed the details of your flight. I understand your flight AC 871 from Paris Charles de Gaulle (CDG) to Toronto (YYZ) on June 8, 2026 was delayed by 4 hours. However, you are not eligible for compensation at this time. After a full review, we can confirm that severe weather was the primary reason. Since the delay was caused by extraordinary circumstances beyond the airline's control, compensation is not required under the EU Air Passenger Rights regulations (EU 261/2004). If you have travel insurance, you may want to contact your insurance provider to see if your policy offers any coverage for this situation."

NO PAYMENT FLOW (skipped entirely for not eligible)
NO IDV (not required for not eligible)
CASE CREATION (GLOB-09):
Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your claim details."
And an alert information is displayed: "Claim submission successful!"
And the system appends the booking record to the case automatically

NOTIFICATION (Adobe):
Then the system triggers notification via Adobe:
And a Not Eligible notification email is sent to j***@gmail.com
And the email contains: Case Reference, flight details (AC 871 CDG?YYZ, delayed 4h), not eligible reason (extraordinary circumstances � severe weather, arrival delay code 72), regulation reference (EU 261 Article 5(3)), insurance suggestion, contact information

END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"

I would like you to � new flow

No

And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given the case has been created for claimant "Julien Marchand" with PNR "TC112"
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
    And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
    And the Case Status should be "Closed � Not Eligible"
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be correct
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel should NOT be greyed out
    And the Claimant Name should be "Julien Marchand"
    And the Claimant Type should be "Adult"
    And the Authentication should be "Pass"
    And the PNR should be "TC112"
    And the PNR Creation Date should be populated
    And the Journey ID should be populated
    And the Booking Source should be populated
    And the Booking Office ID should be populated
    And the Regime should be "EU 261 (EU Mainland)"
    And the Full Name should be "Julien Marchand"
    And the Tags should include "Claimant" and "Adult"
    And the Email should be "j***@gmail.com"
    And the Phone should be "+33***234"
    And the Address should be populated
    And the Aeroplan should be "Not linked"
    And the Profile ID should be populated
    And the Tier Status should be populated
    And the Journey should show "Bound 1: CDG ? YYZ" with claim filed for this flight as arrived late plus 4h
    And the Ancillary Fee section should be present
    And the expected ancillary fees should be none
    And the Eligibility and Compensation section should be present and show "NOT ELIGIBLE" with reason "Extraordinary circumstances � severe weather, arrival delay code 72 � EU 261 Article 5(3)"
    And the delay should be 4hrs which would be eligible if controllable as long-haul greater than 3500km CDG to YYZ approximately 5900km equals �600 but extraordinary overrides
    And the Decision Assist Panel should auto-appear for FD topic
    And DDS should have run automatically with no agent action needed
    And the eligibility decision should be pre-populated as "NOT ELIGIBLE" due to extraordinary circumstances with arrival delay code 72 and weather and delay 4h and long-haul greater than 3500km
    And the Fallback flag should be FALSE as arrival code is available Code 72
    And the Sister City flag should be FALSE
    And the Duplicate Check should have run automatically using baseline data "Julien Marchand + TC112 + CDG?YYZ + FD"
    And the result should be "No duplicate found"
    And no Duplicate Warning Banner should be displayed
    And the Related Cases tab should show no related cases
    And CyberSource should NOT have been triggered as it only runs for eligible cases
    And the system should have appended the booking record automatically for identified and authenticated user
    And Trip Tracer poll should NOT be required
    And the agent should have used pull case from My Activities
    And the case status should have transitioned from "Assigned" to "In Progress"
    And a case acknowledgement notification should have been sent
    And a not eligible notification email should have been sent via Adobe to "j***@gmail.com" containing Case Reference and flight details AC 871 CDG to YYZ delayed 4h and not eligible reason extraordinary circumstances severe weather arrival delay code 72 and regulation reference EU 261 Article 5(3) and insurance suggestion and contact information
    And the Agent Notes section should be accessible
    And the Audit Log should record all actions with timestamps and before/after values
    And Customer Communications should show the not eligible notification email chronologically
    And the chatbot transcript should be accessible and linked to the case
    And the Attachments tab should be empty
    And the Final Status should be "Closed � Not Eligible"
    And the case should be in read-only mode with no editable Decision Assist fields
    And the agent should not be able to access Case Search as it is for leads and management only

PAYMENT VALIDATION
    Given the eligibility result is "NOT ELIGIBLE" due to extraordinary circumstances severe weather
    Then no payment flow should be triggered
    And no country of residence should have been asked
    And no compensation record should have been created
    And no batch file should have been dispatched
    And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section

Expected Results:
DDS returns FD-EU-NE-23. Trip Tracer: Flight operated; Promise = 16:00; Actual = 20:00; Arrival delay = 4hrs; Arrival Delay Code 72 ; CDG?YYZ = ~5,900km (long-haul >3500km); Fallback = FALSE (arrival code available); Sister City = FALSE. CRITICAL: 4hr delay meets 3hr threshold . But arrival delay code 72 = Extraordinary ? airline exempt under Article 5(3). Weather is outside airline control regardless of delay duration. Dual regime assessment: EU 261 = NE-23 (Extraordinary, Weather, Delay at Arrival); APPR = NE (Uncontrollable, Weather). Both regimes = Not Eligible. Result: NOT ELIGIBLE, �0. CyberSource: NOT triggered. IDV: NOT required. Payment: NONE. Claims Dashboard: EU Mainland NE-23; NOT ELIGIBLE; Travel Completed; Arrival Delay Code 72 (Weather, Extraordinary); Delay = 4hrs (would be �600 if controllable); �0; DDS = FD-EU-NE-23.