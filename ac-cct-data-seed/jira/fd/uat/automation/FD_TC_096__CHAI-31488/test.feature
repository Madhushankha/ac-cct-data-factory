Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "I flew from Montreal to Frankfurt on Air Canada and then from Frankfurt to Munich on Lufthansa. The Lufthansa flight was delayed 4 hours. Can I get compensation?"

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
And the user provides "Francine Dub�"
Then the chatbot responds:
"Thanks, Francine! And, what is your booking reference number?"
And the user provides "PNR: TC055"
Then the chatbot searches Trip Tracer for PNR: TC055
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer

AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:

Email: f***@gmail.com

Phone: +1***234

And the user selects "Email: f***@gmail.com"
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

Francine Dub� (Adult)

Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED

JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:

Segment 1: Flight AC 870, Montreal (YUL) ? Frankfurt (FRA), June 8, 2026 � COMPLETED (AC operated)

Segment 2: Flight LH 471, Frankfurt (FRA) ? Munich (MUC), June 8, 2026 � ARRIVED LATE (+4h) (Operated by Lufthansa)

Is this the journey you'd like to check?"
And the user confirms "Yes"

SEGMENT CHECK (GenUC-18):
Then the chatbot checks: More than 1 segment on selected journey? ? YES (2 segments)
Then the chatbot identifies: Segment 1 COMPLETED on time (AC), Segment 2 DELAYED +4h (Lufthansa � Star Alliance)

MSL DETERMINATION:
Then the system calculates MSL using available timing data:

Segment 1 (AC 870): Scheduled arrival 07:30, Actual arrival 07:25 ? No delay

Segment 2 (LH 471): Scheduled arrival 11:00, Actual arrival 15:00 ? 4hr delay

MSL = Segment 2 (LH 471) � largest delay

MSL CHECK � STAR ALLIANCE PARTNER:
Then the system checks MSL for operating carrier on the disrupted leg
And MSL returns: Segment 2 operated by Lufthansa (LH) ? Star Alliance partner
And the system checks: Is Lufthansa a Star Alliance partner? ? YES
And the system determines: MSL on Star Alliance partner ? AC does not auto-assess ? STARQUEST CASE ? MANUAL HANDLING

STAR ALLIANCE PARTNER RESULT (MSL=Star):
Then the chatbot displays:
"I've reviewed your flight details and noticed that this trip was operated by our Star Alliance partner. To complete this claim, I can forward your details to an agent for review. Would you like to proceed?"
And the user selects "Yes"

STARQUEST CASE CREATION:
Then the system creates a StarQuest case for manual agent handling
And the case is routed to the StarQuest team
And the case contains: PNR TC055, passenger Francine Dub�, journey YUL?FRA?MUC, MSL on Lufthansa LH 471, scheduled arrival 11:00, actual arrival 15:00, delay 4h, Star Alliance partner flag
Then the chatbot responds:
"Thank you. Your claim has been forwarded to our team for review. You will receive an update via email once the review is complete. Please allow additional processing time as this involves coordination with our Star Alliance partner."
And an alert information is displayed: "Claim forwarded for review!"

NO DDS AUTO-EVALUATION (skipped � Star Alliance partner, manual handling required)
NO PAYMENT FLOW (skipped � pending manual review)
NO IDV (skipped � pending manual review)
NO FRAUD SCREENING (skipped � pending manual review)

END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"

I would like you to � new flow

No

And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given the case has been created for claimant "Francine Dub�" with PNR "TC055"
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
    And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
    And the Case Status should be "Forwarded � StarQuest Review"
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be "StarQuest Team"
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel may be restricted as it is pending manual review
    And the Claimant Name should be "Francine Dub�"
    And the Claimant Type should be "Adult"
    And the Authentication should be "Pass"
    And the PNR should be "TC055"
    And the PNR Creation Date should be populated
    And the Journey ID should be populated
    And the Booking Source should be populated
    And the Booking Office ID should be populated
    And the Regime should be "APPR"
    And the Full Name should be "Francine Dub�"
    And the Tags should include "Claimant" and "Adult"
    And the Email should be "f***@gmail.com"
    And the Phone should be "+1***234"
    And the Address should be populated
    And the Aeroplan should be "Not linked"
    And the Profile ID should be populated
    And the Tier Status should be populated
    And the Journey should show "Segment 1: YUL ? FRA" as completed and AC operated and "Segment 2: FRA ? MUC" with claim filed and Lufthansa operated with 4h delay
    And the Ancillary Fee section should be present
    And the expected ancillary fees should be none
    And the Eligibility and Compensation section should be present and show "NOT AUTO-ASSESSED" with reason "Star Alliance partner � forwarded to StarQuest for manual handling"
    And the Decision Assist Panel should auto-appear for FD topic
    And DDS should NOT have been auto-evaluated as Star Alliance partner requires manual handling
    And the eligibility decision should be "PENDING" for StarQuest manual review
    And the Duplicate Check should have run automatically using baseline data "Francine Dub� + TC055 + FRA?MUC + FD"
    And the result should be "No duplicate found"
    And no Duplicate Warning Banner should be displayed
    And the Related Cases tab should show no related cases
    And CyberSource should NOT have been triggered as it is pending manual review
    And the system should have appended the booking record automatically for identified and authenticated user
    And Trip Tracer poll should NOT be required
    And the case should be routed to StarQuest Team and not the regular agent queue
    And a case forwarded notification should have been sent
    And an email should have been sent to "f***@gmail.com" confirming claim forwarded for Star Alliance partner review
    And the Agent Notes section should be accessible
    And the Audit Log should record case creation and StarQuest routing with timestamps
    And Customer Communications should show the forwarded notification email
    And the chatbot transcript should be accessible and linked to the case
    And the Attachments tab should be empty
    And the Case Status should be "Forwarded � StarQuest Review" pending manual review
    And the case should NOT be in read-only mode as it is pending StarQuest team action
    And the agent should not be able to access Case Search as it is for leads and management only

PAYMENT VALIDATION
    Given no determination was made due to Star Alliance partner operated segment
    Then no automated payment flow should be triggered
    And the case was created and sent to agent for manual handling
    And no country of residence should have been asked
    And no compensation record should have been created automatically
    And no batch file should have been dispatched
    And if the agent later determines eligible manual compensation should be created and payment dispatched per type with cash to Unifier and e-credit to EIP
    And the Claims Dashboard should show case status as "No Determination" with no payout section until manually resolved

Expected Results:
DDS identifies MSL using available flight timing data:
Segment 1 (AC 870): Scheduled arrival 07:30, Actual arrival 07:25 ? 0 delay
Segment 2 (LH 471): Scheduled arrival 11:00, Actual arrival 15:00 ? 4hr delay
MSL = Segment 2 (LH 471)
MSL Carrier = Lufthansa (LH) � Star Alliance partner
AC Responsibility = AC does not auto-assess for Star Alliance partner disruptions
Outcome = STARQUEST CASE (forwarded to agent for manual handling with partner coordination)
DDS Code = FD-APPR-ND-02
Claims Dashboard: Case created, Status = Forwarded � StarQuest Review, pending manual resolution