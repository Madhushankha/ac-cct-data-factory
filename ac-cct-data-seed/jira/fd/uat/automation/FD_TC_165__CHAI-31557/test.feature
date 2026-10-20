Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "I flew from Tel Aviv to Toronto on Air Canada and then from Toronto to Vancouver on WestJet. The WestJet flight was delayed 5 hours. Can I get compensation?"
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
And the user provides "Boaz Kimchi"
Then the chatbot responds:
"Thanks, Boaz! And, what is your booking reference number?"
And the user provides "PNR: TC139"
Then the chatbot searches Trip Tracer for PNR: TC139
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer
AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
� Email: b***@gmail.com
� Phone: +972***456
And the user selects "Email: b***@gmail.com"
Then the chatbot responds:
"I've sent a verification code to your email, please enter it within 15 minutes of receiving it."
And the user provides the OTP code "739281"
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
� Boaz Kimchi (Adult)
Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED
JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
� Segment 1: Flight AC 084, Tel Aviv Ben Gurion (TLV) ? Toronto (YYZ), June 11, 2026 � COMPLETED (AC operated)
� Segment 2: Flight WS 3421, Toronto (YYZ) ? Vancouver (YVR), June 11, 2026 � ARRIVED LATE (+5h) (Operated by WestJet)
Is this the journey you'd like to check?"
And the user confirms "Yes"
SEGMENT CHECK (GenUC-18):
Then the chatbot checks: More than 1 segment on selected journey? ? YES (2 segments)
Then the chatbot identifies: Segment 1 COMPLETED (AC), Segment 2 DELAYED (WestJet � non-Star Alliance OAL)
Then the chatbot determines: MSL = Segment 2 (WS 3421 � the disrupted leg)
MSL CHECK � NON-STAR ALLIANCE OAL:
Then the system checks MSL for operating carrier on the disrupted leg
And MSL returns: Segment 2 operated by WestJet (WS) ? Non-Star Alliance OAL
And the system checks: Is WestJet a Star Alliance partner? ? NO
And the system determines: MSL on non-Star Alliance OAL ? SYSTEM POLLS FOR OAL DATA ? IF UNAVAILABLE AFTER 14 DAYS ? MANUAL HANDLING
NON-STAR ALLIANCE OAL RESULT:
Then the chatbot displays:
"I've reviewed your flight details and noticed that the disrupted flight was operated by another airline. To complete this claim, I can forward your details to an agent for review. Would you like to proceed?"
And the user selects "Yes"
CASE CREATION:
Then the system creates a case for manual agent handling
And the case is placed in the System Processing Queue
And the system begins polling for WestJet disruption data (daily for up to 14 days)
And the case contains: PNR TC139, passenger details, journey details, MSL on WestJet WS 3421, delay 5h, non-Star Alliance OAL flag, ASL regime
Then the chatbot responds:
"Thank you. Your claim has been forwarded to our team for review. You will receive an update via email once the review is complete. Please allow additional processing time as this involves coordination with another airline."
And an alert information is displayed: "Claim forwarded for review!"
NO DDS AUTO-EVALUATION (skipped � non-Star Alliance OAL, polling required)
NO PAYMENT FLOW (skipped � pending review)
NO IDV (skipped)
NO FRAUD SCREENING (skipped)
END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given the case has been created for claimant "Boaz Kimchi" with PNR "TC139"
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
    And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
    And the Case Status should be "Pending Agent Review" placed in System Processing Queue with polls for OAL data up to 14 days and escalation if unavailable
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be "System Processing Queue" initially transitioning to "Manual Review Agent Queue" after 14-day exhaustion if data unavailable
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel should be greyed out or not applicable as it is pending OAL data polling or manual handling
    And the Claimant Name should be "Boaz Kimchi"
    And the Claimant Type should be "Adult"
    And the Authentication should be "Pass"
    And the PNR should be "TC139"
    And the PNR Creation Date should be populated
    And the Journey ID should be populated
    And the Booking Source should be populated
    And the Booking Office ID should be populated
    And the Regime should be "ASL (Israel origin � TLV)"
    And the Full Name should be "Boaz Kimchi"
    And the Tags should include "Claimant" and "Adult"
    And the Email should be "b***@gmail.com"
    And the Phone should be "+972***456"
    And the Journey should show "Segment 1: TLV ? YYZ" as completed and AC operated and "Segment 2: YYZ ? YVR" delayed plus 5h and WestJet WS 3421 operated as non-Star Alliance OAL
    And the MSL should be Segment 2 WestJet as non-Star Alliance
    And this should differ from TC140 where Star Alliance results in immediate StarQuest routing whereas here non-Star OAL means system polls for data up to 14 days then escalates if unavailable
    And the Ancillary Fee section should be present
    And the expected ancillary fees should be none
    And the Eligibility and Compensation section should be present and show "NO DETERMINATION" with reason "MSL on non-Star Alliance OAL; system polling for WestJet data; if unavailable after 14 days manual handling"
    And the Decision Assist Panel should NOT have been auto-evaluated as it was skipped due to non-Star Alliance OAL requiring polling before assessment
    And DDS should NOT have run automatically
    And the status should be "Pending � OAL Data Polling"
    And the Duplicate Check should have run automatically using baseline data "Boaz Kimchi + TC139 + TLV?YVR + FD"
    And the result should be "No duplicate found"
    And CyberSource should NOT have been triggered as it is No Determination pending data or review
    And the system should have appended the booking record automatically for identified and authenticated user
    And the case should be placed in System Processing Queue polling for OAL data
    And if data is unavailable after 14 days the case should be escalated to Manual Review Agent Queue
    And a case forwarded notification should have been sent
    And an email should have been sent to "b***@gmail.com" containing Case Reference and flight details Leg 2 WS 3421 YYZ to YVR delayed 5h and status forwarded for review and additional processing time note coordination with another airline
    And the Agent Notes section should be accessible
    And the Audit Log should record case creation and System Processing Queue placement and OAL polling status
    And Customer Communications should show the forwarded notification
    And the chatbot transcript should be accessible and linked to the case
    And the Attachments tab should be empty
    And the Current Status should be "Pending Agent Review" in System Processing Queue polling
    And the case should NOT be in read-only mode as the agent can update after manual review
    And the agent should not be able to access Case Search as it is for leads and management only

PAYMENT VALIDATION
    Given no determination was made due to OAL data polling for non-Star Alliance partner
    Then no automated payment flow should be triggered
    And the case was created and sent to agent for manual handling
    And no country of residence should have been asked
    And no compensation record should have been created automatically
    And no batch file should have been dispatched
    And if the agent later determines eligible manual compensation should be created and payment dispatched per type with cash to Unifier and e-credit to EIP
    And the Claims Dashboard should show case status as "No Determination" with no payout section until manually resolved

Expected Results:
DDS returns FD-ASL-ND-01. Trip Tracer: AC leg = Completed; OAL leg = Disrupted; MSL = OAL leg (non-Star Alliance); OAL disruption data = NOT AVAILABLE (no data-sharing agreement). No Determination: Cannot assess eligibility � MSL is on a carrier AC has no data access to. Customer Redirect: Directed to contact the operating OAL directly for their disruption claim. Compensation: NOT CALCULATED. Fraud Screening: NOT INVOKED. Regime Assessment: ASL = ND-01 (OAL, non-Star, redirect); APPR = ND (same gap). Claims Dashboard: Status = No Determination; Reason = MSL on non-Star OAL (data unavailable); Redirect = OAL; DDS = FD-ASL-ND-01.