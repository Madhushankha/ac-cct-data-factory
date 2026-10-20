Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight from London to Toronto was delayed 4 hours due to severe weather. I'd like to check if I'm eligible for compensation"
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
And the user provides "Roger Whitehall"
Then the chatbot responds:
"Thanks, Roger! And, what is your booking reference number?"
And the user provides "PNR: TC151"
Then the chatbot searches Trip Tracer for PNR: TC151
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer
AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
� Email: r***@gmail.com
� Phone: +44***789
And the user selects "Email: r***@gmail.com"
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
� Roger Whitehall (Adult)
Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED
JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
� Flight: AC 855
� Route: London Heathrow (LHR) ? Toronto (YYZ)
� Date: June 5, 2026
� Arrival Delay: 4 hours
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
Then the chatbot checks: Filing deadline for EU 261 (UK = 6 years) and APPR ? within limitation ? PROCEED
REGIME DETERMINATION � DUAL REGIME:
Then the system determines applicable regimes:
And the system checks: Origin airport = LHR (London, UK) ? EU 261 applies
And the system checks: Destination airport = YYZ (Toronto, Canada) ? APPR applies
And the system determines: DUAL REGIME � EU 261 + APPR
TRIAGE & DDS EVALUATION � BOTH NOT ELIGIBLE:
Then the DDS evaluation is done in backend
And DDS assesses BOTH regimes independently:
EU 261 ASSESSMENT:
? Origin: LHR (UK) ? EU 261 applies
? Distance: LHR?YYZ = ~5,550 km ? Long-haul (>3500km)
? Delay: 4 hours ? ?4h threshold
? Code: 72 (Weather)
? EU 261 Controllability: EXTRAORDINARY CIRCUMSTANCES (weather is extraordinary under EU 261)
? EU 261 Result: NOT ELIGIBLE (extraordinary circumstances exemption)
APPR ASSESSMENT:
? Destination: YYZ (Canada) ? APPR applies
? Delay: 4 hours ? 3�6h tier
? Code: 72 (Weather)
? APPR Controllability: UNCONTROLLABLE (weather is uncontrollable under APPR)
? APPR Result: NOT ELIGIBLE (uncontrollable disruption)
DUAL REGIME � BOTH NOT ELIGIBLE:
? EU 261: NOT ELIGIBLE (extraordinary circumstances)
? APPR: NOT ELIGIBLE (uncontrollable)
? Any regime eligible? ? NO
? Final Result: DEFINITIVELY NOT ELIGIBLE � $0 COMPENSATION
TRIP TRACER UI VALIDATION:
Then the tester opens Trip Tracer UI for PNR: TC151
? Promised Itinerary - Flight: AC 855, Route: LHR ? YYZ, Scheduled Arrival: 16:00
? Current Itinerary - Flight: AC 855, Route: LHR ? YYZ, Status: ARRIVED LATE, Actual: 20:00, Delay: +4H 00M
? Dual Regime: EU 261 + APPR
? EU 261: NOT ELIGIBLE � Extraordinary Circumstances (Code 72 � Weather)
? APPR: NOT ELIGIBLE � Uncontrollable (Code 72 � Weather)
? Both Regimes: NOT ELIGIBLE
? Final Result: NOT ELIGIBLE � $0
? MSL FLIGHT: AC 855 � LHR ? YYZ � 72
? EXTRAORDINARY / UNCONTROLLABLE (Code 72)
Flight Compensation:
? MR ROGER WHITEHALL | NOT ELIGIBLE | BOTH_REGIMES_NOT_ELIGIBLE | $0
FRAUD SCREENING � NOT TRIGGERED:
CyberSource is ONLY called for ELIGIBLE cases ? NOT invoked
NOT ELIGIBLE RESULT (FD-05b):
Then the chatbot displays:
"I've reviewed the details of your flight. I understand your flight AC 855 from London Heathrow (LHR) to Toronto (YYZ) on June 5, 2026 was delayed by 4 hours. However, you are not eligible for compensation at this time. After a full review, we can confirm that severe weather was the primary reason. Since the delay was caused by extraordinary circumstances beyond the airline's control, compensation is not required under the applicable regulations. If you have travel insurance, you may want to contact your insurance provider to see if your policy offers any coverage for this situation."
NO PAYMENT FLOW (skipped entirely for not eligible)
NO IDV (not required for not eligible)
CASE CREATION (GLOB-09):
Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your claim details."
And an alert information is displayed: "Claim submission successful!"
And the system appends the booking record to the case automatically
NOTIFICATION (Adobe):
Then the system triggers notification via Adobe:
And a Not Eligible notification email is sent to r***@gmail.com
And the email contains: Case Reference, flight details, not eligible reason (extraordinary circumstances / uncontrollable � weather, both regimes assessed), regulation references (EU 261 + APPR), insurance suggestion, contact information
END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given the case has been created for claimant "Roger Whitehall" with PNR "TC151"
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
    And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
    And the Case Status should be "Closed � Not Eligible"
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be correct
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel should NOT be greyed out
    And the Claimant Name should be "Roger Whitehall"
    And the Claimant Type should be "Adult"
    And the Authentication should be "Pass"
    And the PNR should be "TC151"
    And the Regime should be "EU 261 + APPR (Dual Regime � BOTH Not Eligible)"
    And the Full Name should be "Roger Whitehall"
    And the Tags should include "Claimant" and "Adult"
    And the Aeroplan should be "Not linked"
    And the Journey should show "Bound 1: LHR ? YYZ" with claim filed for this flight
    And the Ancillary Fee section should be present
    And the expected ancillary fees should be none
    And Assessment 1 should show EU 261 with disruption code 72 Weather and classification under EU rules as Extraordinary circumstances and eligibility NOT ELIGIBLE under EU 261 Article 5(3) and compensation �0
    And Assessment 2 should show APPR with disruption code 72 Weather and classification under APPR rules as Uncontrollable and eligibility NOT ELIGIBLE and compensation $0
    And BOTH regimes should be assessed and BOTH should return Not Eligible
    And the system should NOT keep searching for an eligible regime as when all applicable regimes are NE the final answer is definitively NE
    And the Total Compensation should be $0 with no regime providing eligibility
    And the Decision Assist Panel should auto-appear for FD topic
    And DDS should have run automatically
    And BOTH regimes should be assessed and logged as BOTH Not Eligible
    And the final determination should be Not Eligible definitively with no eligible regime
    And the Duplicate Check should have run automatically using baseline data "Roger Whitehall + TC151 + LHR?YYZ + FD"
    And the result should be "No duplicate found"
    And no Duplicate Warning Banner should be displayed
    And the Related Cases tab should show no related cases
    And CyberSource should NOT have been triggered as it only runs for ELIGIBLE cases and both regimes are NE
    And the system should have appended the booking record automatically
    And the agent should have used pull case from My Activities
    And the case status should have transitioned from "Assigned" to "In Progress"
    And a case acknowledgement notification should have been sent
    And a not eligible notification email should have been sent via Adobe containing Case Reference and flight details and not eligible reason extraordinary or uncontrollable weather and both regimes assessed and insurance suggestion
    And the Agent Notes section should be accessible
    And the Audit Log should record dual-regime assessment with EU 261 NE extraordinary and APPR NE uncontrollable
    And Customer Communications should show the not eligible notification email chronologically
    And the chatbot transcript should be accessible and linked to the case
    And the Attachments tab should be empty
    And the Final Status should be "Closed � Not Eligible"
    And the case should be in read-only mode with no editable Decision Assist fields
    And the agent should not be able to access Case Search as it is for leads and management only

PAYMENT VALIDATION
    Given the eligibility result is "NOT ELIGIBLE" with both regimes returning Not Eligible
    Then no payment flow should be triggered
    And no country of residence should have been asked
    And no payment method should have been determined
    And no bank details should have been collected
    And no IDV should have been required
    And no compensation record should have been created
    And no batch file should have been dispatched
    And CyberSource should NOT have been triggered as it only runs for ELIGIBLE cases and both regimes are NE
    And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" for both regimes with no compensation record and no payout section
    And both regimes should be assessed independently with EU 261 Not Eligible due to extraordinary circumstances weather Code 72 and APPR Not Eligible due to uncontrollable weather Code 72
    And the system should NOT keep searching for an eligible regime as when all applicable regimes are NE the final answer is definitively NE
    And the Total Compensation should be $0

Expected Results:
DDS returns FD-MIXED-NE-02. Trip Tracer: Promise = 16:00; Actual = 20:00; Delay = 4hrs; MSL = Leg 1; Code 72; EU = Extraordinary; APPR = Uncontrollable; Regime = EU 261 + APPR. Dual Assessment: EU 261 = NOT ELIGIBLE (extraordinary � weather); APPR = NOT ELIGIBLE (uncontrollable � weather). CRITICAL: Both regimes assessed, both return NE. System must NOT keep searching for an eligible regime � when all applicable regimes are NE, the final answer is definitively NE. Compensation: $0 � no regime provides eligibility. Claims Dashboard: EU 261 = Not Eligible (extraordinary); APPR = Not Eligible (uncontrollable); Both assessed, both NE; Final = Not Eligible; DDS = FD-MIXED-NE-02.