Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight from London Heathrow to Toronto was cancelled due to severe weather and I didn't take any replacement flight. Can I get compensation?"

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
And the user provides "Alice Whitfield"
Then the chatbot responds:
"Thanks, Alice! And, what is your booking reference number?"
And the user provides "PNR: TC099"
Then the chatbot searches Trip Tracer for PNR: TC099
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer

AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:

Email: a***@gmail.com

Phone: +44***789

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

Alice Whitfield (Adult)

Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED

JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:

Flight: AC 849

Route: London Heathrow (LHR) ? Toronto (YYZ)

Date: May 25, 2026

Status: CANCELLED

Is this the journey you'd like to check?"
And the user confirms "Yes"

SEGMENT CHECK:
Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18

DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for this passenger + journey combination

72-HOUR CHECK:
Then the chatbot checks: Hours since scheduled departure
And the system calculates: Scheduled departure was May 25, 2026; current date is June 25, 2026 ? >72 hours ? PROCEED

CLAIM TIME LIMIT CHECK:
Then the chatbot checks: Filing deadline for EU 261 (UK) = 6 years ? within limitation ? PROCEED

REGIME DETERMINATION:
Then the system determines: Origin = LHR (UK) ? EU 261 (UK)
And the system checks: Customer did NOT travel ? No Travel Origin (remained at LHR)

TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS Evaluates and sends to Trip Tracer UI:

Trip Tracer UI Validation
Then the tester opens Trip Tracer UI for PNR: TC099

? Promised Itinerary - Flight: AC 849, Route: LHR ? YYZ, Scheduled Departure: 10:00, Scheduled Arrival: 13:00 (local YYZ)

? Current Itinerary - Flight: AC 849, Route: LHR ? YYZ, Status: CANCELLED

? Customer Status: NO TRAVEL - ORIGIN (customer remained at LHR, declined rebooking)

? History - No rebooking accepted

? Regime: EU 261 (UK) (UK origin � LHR)

? MSL FLIGHT: AC 849 � LHR ? YYZ

? Cancellation Code: WEAT � 4-character Netline code

? "Cancellation � severe weather"

? UNCONTROLLABLE (WEAT is in the Uncontrollable cancellation code list: AIRS, ARPT, DAMA, INDU, POLI, RUNW, WEAT)

? EU 261: Extraordinary circumstances (Article 5(3)) ? NOT ELIGIBLE

? Disruption Type: CANCELLATION

? Fallback: FALSE (cancellation code WEAT available)

Flight Compensation:

? MS ALICE WHITFIELD | NOT ELIGIBLE | EXTRAORDINARY_CIRCUMSTANCES | EUR 0.00

FRAUD SCREENING � NOT TRIGGERED:
CyberSource is ONLY called for ELIGIBLE cases ? NOT invoked for Not Eligible outcomes

NOT ELIGIBLE RESULT (FD-05b):
Then the chatbot displays:
"I've reviewed the details of your flight. I understand your flight AC 849 from London Heathrow (LHR) to Toronto (YYZ) on May 25, 2026 was cancelled. However, you are not eligible for compensation at this time. After a full review, we can confirm that severe weather was the primary reason. Since the cancellation was caused by extraordinary circumstances beyond the airline's control, compensation is not required under the UK Air Passenger Rights regulations (EU 261). If you have travel insurance, you may want to contact your insurance provider to see if your policy offers any coverage for this situation."

NO PAYMENT FLOW (skipped entirely for not eligible)
NO IDV (not required for not eligible)
CASE CREATION (GLOB-09):
Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your claim details."
And an alert information is displayed: "Claim submission successful!"
And the system appends the booking record to the case automatically

NOTIFICATION (Adobe):
Then the system triggers notification via Adobe:
And a Not Eligible notification email is sent to a***@gmail.com
And the email contains: Case Reference, flight details (LHR?YYZ CANCELLED), not eligible reason (extraordinary circumstances � severe weather, cancellation code WEAT), regulation reference (EU 261 Article 5(3)), insurance suggestion, contact information

END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"

I would like you to � new flow

No

And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given the case has been created for claimant "Alice Whitfield" with PNR "TC099"
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Cancellation"
    And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
    And the Case Status should be "Closed � Not Eligible"
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be correct
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel should NOT be greyed out
    And the Claimant Name should be "Alice Whitfield"
    And the Claimant Type should be "Adult"
    And the Authentication should be "Pass"
    And the PNR should be "TC099"
    And the Regime should be "EU 261 (UK)"
    And the Full Name should be "Alice Whitfield"
    And the Tags should include "Claimant" and "Adult"
    And the Email should be "a***@gmail.com"
    And the Phone should be "+44***789"
    And the Journey should show "Bound 1: LHR ? YYZ" with claim filed for this flight as cancelled
    And the Eligibility and Compensation section should be present and show "NOT ELIGIBLE" with reason "Extraordinary circumstances � severe weather"
    And the Cancellation Code should be "WEAT" as a 4-character Netline code indicating Uncontrollable
    And EU 261 Article 5(3) exemption should be applied
    And the compensation should be "�0 / �0"
    And DDS should have run automatically
    And the eligibility decision should be pre-populated as "NOT ELIGIBLE" due to extraordinary circumstances with cancellation code WEAT as Uncontrollable
    And the No Travel status should be "Origin"
    And the Duplicate Check should have run automatically and the result should be "No duplicate found"
    And CyberSource should NOT have been triggered as it only runs for eligible cases
    And the system should have appended the booking record automatically
    And a not eligible notification email should have been sent to "a***@gmail.com" containing extraordinary circumstances severe weather and EU 261 Article 5(3) and insurance suggestion
    And the Final Status should be "Closed � Not Eligible"
    And the case should be in read-only mode
    And the agent should not be able to access Case Search as it is for leads and management only

PAYMENT VALIDATION
    Given the eligibility result is "NOT ELIGIBLE" due to extraordinary circumstances severe weather
    Then no payment flow should be triggered
    And no country of residence should have been asked
    And no compensation amount should have been offered
    And no Aeroplan or AC Wallet check should have occurred
    And no payment method selection should have occurred
    And no IDV Persona should have been required
    And no CyberSource fraud screening should have occurred
    And no compensation record should have been created in the backend
    And no batch file should have been dispatched
    And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section

Expected Results:
DDS returns FD-EU-NE-07. Trip Tracer: CANCELLED; MSL = Leg 1 (AC 849 LHR?YYZ); Cancellation Code = WEAT; No Travel = Origin (customer remained at LHR); Fallback = FALSE; EU 261 (UK). EU 261 Extraordinary Circumstances: Article 5(3) � airline exempt from compensation when disruption caused by extraordinary circumstances beyond its control. Result: NOT ELIGIBLE, �0/�0. CyberSource: NOT triggered. IDV: NOT required. Payment: NONE. Claims Dashboard: EU-UK NE-07; NOT ELIGIBLE; Extraordinary Circumstances (WEAT); No Travel = Origin; Cancellation; DDS = FD-EU-NE-07.