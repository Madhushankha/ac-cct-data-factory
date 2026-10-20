Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight from Toronto to Frankfurt was delayed about 2 hours and I arrived in Tel Aviv about an hour and a half late. Can I get compensation under Israeli regulations?"
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
And the user provides "Shai Benvenisti"
Then the chatbot responds:
"Thanks, Shai! And, what is your booking reference number?"
And the user provides "PNR: TC137"
Then the chatbot searches Trip Tracer for PNR: TC137
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer
AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
Email: s***@gmail.com
Phone: +1***234
And the user selects "Email: s***@gmail.com"
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
Shai Benvenisti (Adult)
Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED
JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
Segment 1: Flight AC 873, Toronto (YYZ) ? Frankfurt (FRA), June 9, 2026 � ARRIVED LATE (+2h)
Segment 2: Flight AC 9042, Frankfurt (FRA) ? Tel Aviv Ben Gurion (TLV), June 9, 2026 � ARRIVED ON TIME
Is this the journey you'd like to check?"
And the user confirms "Yes"
SEGMENT CHECK (GenUC-18):
Then the chatbot checks: More than 1 segment on selected journey? ? YES (2 segments)
Then the chatbot identifies: Segment 1 ARRIVED LATE (MSL), Segment 2 ARRIVED ON TIME
Then the chatbot determines: Final destination = TLV; Final arrival delay = 1.5h
DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for this passenger + journey combination
72-HOUR CHECK:
Then the chatbot checks: Hours since last leg arrival
And the system calculates: Arrival was June 9, 2026; current date is June 25, 2026 ? >72 hours ? PROCEED
CLAIM TIME LIMIT CHECK:
Then the chatbot checks: Filing deadline for ASL = 1,460 days (4 years) from MSL scheduled departure date ? within limitation ? PROCEED
REGIME DETERMINATION:
Then the system determines: Destination = TLV (Israel) ? ASL applies
And the system checks: Travel Completed ? ASL threshold = 8 hours ? 1.5hrs < 8hrs ? well below threshold
TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS Evaluates and sends to Trip Tracer UI:
Trip Tracer UI Validation
Then the tester opens Trip Tracer UI for PNR: TC137
? Segment 1: Flight: AC 873, Route: YYZ ? FRA, Scheduled Arrival: 08:00, Actual: 10:00, Delay: +2H 00M (MSL)
? Arrival Delay Code on Leg 1: 42 � numeric delay code (Not Extraordinary Circumstance � controllable)
? Segment 2: Flight: AC 9042, Route: FRA ? TLV, Scheduled Arrival: 18:00, Actual: 19:30, Delay: +1H 30M
? Final Destination: TLV
? Final Arrival Delay: Promised arrival at TLV = 18:00; Actual arrival at TLV = 19:30 ? +1H 30M
? MSL Delay: 2H 00M (Leg 1 � YYZ?FRA) ? also below 3h and well below 8h
? BOTH MSL delay (2h) AND arrival delay (1.5h) are below ALL applicable thresholds:



? Regime: ASL (Israel destination � TLV)
? ASL Travel Completed Threshold: Arrival delay must be ? 8 hours ? 1.5h < 8h ? NOT ELIGIBLE
? Fallback: FALSE (arrival delay code 42 available)
? No ambiguity � insufficient delay at every measurement point under every regime
Flight Compensation:
? MR SHAI BENVENISTI | NOT ELIGIBLE | ARRIVAL_DELAY_BELOW_8_HOURS | ILS 0.00
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
And a Not Eligible notification email is sent to s***@gmail.com
And the email contains: Case Reference, flight details (Seg 1: YYZ?FRA +2h MSL; Seg 2: FRA?TLV; Final arrival TLV +1h30m), not eligible reason (both MSL delay and arrival delay at final destination below 8-hour ASL Travel Completed threshold), regulation reference (ASL), contact information
END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"
I would like you to � new flow
No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given the case has been created for claimant "Shai Benvenisti" with PNR "TC137"
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
    And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
    And the Case Status should be "Closed � Not Eligible"
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be correct
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel should NOT be greyed out
    And the Claimant Name should be "Shai Benvenisti"
    And the Claimant Type should be "Adult"
    And the Authentication should be "Pass"
    And the PNR should be "TC137"
    And the PNR Creation Date should be populated
    And the Journey ID should be populated
    And the Booking Source should be populated
    And the Booking Office ID should be populated
    And the Regime should be "ASL (Israel destination � TLV)"
    And the Full Name should be "Shai Benvenisti"
    And the Tags should include "Claimant" and "Adult"
    And the Email should be "s***@gmail.com"
    And the Phone should be "+1***234"
    And the Address should be populated
    And the Aeroplan should be "Not linked"
    And the Profile ID should be populated
    And the Tier Status should be populated
    And the Journey should show "Segment 1: YYZ ? FRA" arrived late plus 2h as MSL and "Segment 2: FRA ? TLV" arrived on time
    And the Ancillary Fee section should be present
    And the expected ancillary fees should be none
    And the Eligibility and Compensation section should be present and show "NOT ELIGIBLE" with reason "Both MSL delay 2h AND final arrival delay at TLV 1.5h are below 8h ASL Travel Completed threshold"
    And the Decision Assist Panel should auto-appear for FD topic
    And DDS should have run automatically with no agent action needed
    And the eligibility decision should be pre-populated as "NOT ELIGIBLE" due to arrival delay 1.5h being less than 8h ASL Travel Completed threshold and MSL delay 2h also below all thresholds
    And the Duplicate Check should have run automatically using baseline data "Shai Benvenisti + TC137 + YYZ?TLV + FD"
    And the result should be "No duplicate found"
    And no Duplicate Warning Banner should be displayed
    And the Related Cases tab should show no related cases
    And CyberSource should NOT have been triggered as it only runs for eligible cases
    And the system should have appended the booking record automatically for identified and authenticated user
    And Trip Tracer poll should NOT be required
    And the agent should have used pull case from My Activities
    And the case status should have transitioned from "Assigned" to "In Progress"
    And a case acknowledgement notification should have been sent
    And a not eligible notification email should have been sent via Adobe to "s***@gmail.com" containing arrival delay and MSL delay both below 8h ASL Travel Completed threshold and ASL
    And the Agent Notes section should be accessible
    And the Audit Log should record all actions with timestamps and before/after values
    And Customer Communications should show the not eligible notification email chronologically
    And the chatbot transcript should be accessible and linked to the case
    And the Attachments tab should be empty
    And the Final Status should be "Closed � Not Eligible"
    And the case should be in read-only mode with no editable Decision Assist fields
    And the agent should not be able to access Case Search as it is for leads and management only

PAYMENT VALIDATION
    Given the eligibility result is "NOT ELIGIBLE" due to both MSL and final arrival delays below 8-hour ASL threshold
    Then no payment flow should be triggered
    And no country of residence should have been asked
    And no compensation record should have been created
    And no batch file should have been dispatched
    And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section

Expected Results:
DDS returns FD-ASL-NE-23. Trip Tracer: Leg 1 = Delayed 2hrs (Arrival Delay Code 42, Not Extraordinary Circumstance / Controllable); Leg 2 = On time; MSL = Leg 1 (2hr delay); Final arrival delay at TLV = 1.5hrs; Fallback = FALSE (arrival delay code available). Both delays below ALL thresholds: MSL delay 2hrs < 8hrs (ASL Travel Completed) and < 3hrs (No Travel/APPR/EU); Arrival delay 1.5hrs < 8hrs and < 3hrs ? NE under all regimes. 